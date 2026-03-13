/*
 * Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.lib.data.xmldata.utils.xsd;

import io.ballerina.lib.data.xmldata.utils.Constants;
import io.ballerina.lib.data.xmldata.utils.DataUtils;
import io.ballerina.lib.data.xmldata.utils.DiagnosticErrorCode;
import io.ballerina.lib.data.xmldata.utils.DiagnosticLog;
import io.ballerina.runtime.api.flags.SymbolFlags;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

/**
 * Represent xsd sequence.
 *
 * @since 1.1.0
 */
public class SequenceInfo implements ModelGroupInfo {
    public String fieldName;
    public long minOccurs;
    public long maxOccurs;
    public int occurrences;
    private final Map<String, Integer> remainingElementCount = new HashMap<>();
    private final Map<String, Integer> minimumElementCount = new HashMap<>();
    private final Map<String, Integer> maxElementCount = new HashMap<>();
    private final Map<String, Boolean> elementOptionality = new HashMap<>();
    private final List<String> allElements = new ArrayList<>();
    private final List<String> anyAnnotatedFields = new ArrayList<>();
    private final Set<String> nestedSequenceElements = new HashSet<>();
    private final Set<String> nestedSequenceFieldNames = new HashSet<>();
    int currentIndex = 0;
    int elementCount;
    String lastElement = "";
    private boolean isCompleted = false;
    private boolean isMiddleOfElement = false;
    private final Stack<HashMap<String, ElementInfo>> xmlElementInfo;
    private HashMap<String, String> xmlElementNameMap = new HashMap<>();
    private final RecordType fieldType;

    public SequenceInfo(String fieldName, BMap<BString, Object> element, RecordType fieldType,
                        Stack<HashMap<String, ElementInfo>> xmlElementInfo) {
        this.fieldName = fieldName;
        this.fieldType = fieldType;
        if (element.containsKey(Constants.MIN_OCCURS)) {
            this.minOccurs = element.getIntValue(Constants.MIN_OCCURS);
        } else {
            this.minOccurs = 1;
        }

        if (element.containsKey(Constants.MAX_OCCURS)) {
            this.maxOccurs = element.getIntValue(Constants.MAX_OCCURS);
        } else {
            this.maxOccurs = Math.max(this.minOccurs, 1);
        }
        this.occurrences = 0;
        this.xmlElementInfo = xmlElementInfo;
        updateUnvisitedElementsBasedOnPriorityOrder(fieldType);
        this.xmlElementNameMap = DataUtils.getXmlElementNameMap(fieldType);
        reOrderElementNamesBasedOnTheNameAnnotation();
        this.elementCount = allElements.size();
        buildNestedSequenceElements(fieldType);
    }

    public void updateOccurrences() {
        this.occurrences++;
        if (this.occurrences > this.maxOccurs) {
            throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_MORE_THAN_MAX_ALLOWED_TIMES, fieldName);
        }
    }

    public void validateMinOccurrences() {
        if (this.occurrences < this.minOccurs) {
            throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_LESS_THAN_MIN_REQUIRED_TIMES, fieldName);
        }
    }

    @Override
    public void validate() {
        generateElementOptionalityMapIfNotPresent();
        validateCompletedSequences();
        reset();
    }

    private void reset() {
        this.isCompleted = false;
        this.isMiddleOfElement = false;
        this.currentIndex = 0;
        this.remainingElementCount.putAll(this.maxElementCount);
        this.lastElement = "";
    }

    @Override
    public void visit(String element, boolean isStartElement) {
        generateElementOptionalityMapIfNotPresent();
        if (isMiddleOfElement && isStartElement) {
            return;
        }

        // Elements that belong to nested sequences are tracked by inner model groups.
        // The outer sequence state is updated via notifyNestedGroupCompleted when the inner group completes.
        if (nestedSequenceElements.contains(element)) {
            return;
        }

        isMiddleOfElement = isStartElement;
        if (isStartElement) {
            isCompleted = false;
            return;
        }

        checkElementOrderAndUpdateElementOccurences(element);
    }

    @Override
    public void notifyNestedGroupCompleted(String fieldName) {
        // Only update state if fieldName is a direct nested sequence field of this group.
        // Other inner model groups (e.g., sequence fields within element-typed fields) are not tracked here.
        if (!nestedSequenceFieldNames.contains(fieldName)) {
            return;
        }
        generateElementOptionalityMapIfNotPresent();
        checkElementOrderAndUpdateElementOccurences(fieldName);
    }

    @Override
    public boolean isElementContains(String elementName) {
        if (elementName == null || elementName.isEmpty()) {
            return false;
        }
        if (this.allElements.contains(elementName)) {
            return true;
        }
        if (!anyAnnotatedFields.isEmpty()) {
            return true;
        }
        if (this.nestedSequenceElements.contains(elementName)) {
            return true;
        }
        return false;
    }

    @Override
    public boolean isMiddleOfModelGroup() {
        return isMiddleOfElement;
    }

    @Override
    public boolean predictStartNewModelGroup(String element) {
        generateElementOptionalityMapIfNotPresent();
        if (!isElementContains(element)) {
            return false;
        }

        boolean isFirstElement = element.equals(allElements.get(0));
        if (isFirstElement && currentIndex == 0 && remainingElementCount.get(allElements.get(0)) > 0) {
            return false;
        }

        return !isMiddleOfElement && isFirstElement
                && (isCompleted || containsAllOptionalElements())
                && !(lastElement.equals(element) && remainingElementCount.get(element) > 0);
    }

    private void validateCompletedSequences() {
        if (!isCompleted && !containsAllOptionalElements()) {
            throw DiagnosticLog.error(DiagnosticErrorCode
                    .REQUIRED_ELEMENT_NOT_FOUND, getUnvisitedElements(), fieldName);
        }
        updateOccurrences();
    }

    private boolean containsAllOptionalElements() {
        for (int i = currentIndex; i < this.elementCount; i++) {
            if (!elementOptionality.get(allElements.get(i))) {
                return false;
            }
        }
        return true;
    }

    private void checkElementOrderAndUpdateElementOccurences(String element) {
        String elementToProcess = element;
        if (!allElements.contains(element) && !anyAnnotatedFields.isEmpty()) {
            elementToProcess = anyAnnotatedFields.get(0);
        }

        String nextElement;
        boolean isLastElement = false;

        if (elementToProcess.equals(lastElement)) {
            nextElement = lastElement;
            isLastElement = true;
        } else {
            nextElement = allElements.get(currentIndex == this.elementCount ? currentIndex - 1 : currentIndex);
        }

        while (!nextElement.equals(elementToProcess)) {
            if (!elementOptionality.get(nextElement)) {
                throw DiagnosticLog.error(DiagnosticErrorCode.INCORRECT_ELEMENT_ORDER,
                        xmlElementNameMap.getOrDefault(element, element), fieldName);
            }
            currentIndex++;
            nextElement = allElements.get(currentIndex);

            if (currentIndex == this.elementCount) {
                throw DiagnosticLog.error(DiagnosticErrorCode.INCORRECT_ELEMENT_ORDER,
                        xmlElementNameMap.getOrDefault(element, element), fieldName);
            }
        }

        if (remainingElementCount.get(nextElement) == 0) {
            if (!anyAnnotatedFields.contains(nextElement)) {
                throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_MORE_THAN_MAX_ALLOWED_TIMES_IN_SEQUENCES,
                        xmlElementNameMap.get(nextElement), fieldName);
            }
        } else {
            remainingElementCount.put(elementToProcess, remainingElementCount.get(nextElement) - 1);
            int elementCount = maxElementCount.get(elementToProcess) - remainingElementCount.get(elementToProcess);

            if (elementCount >= minimumElementCount.get(elementToProcess) && !isLastElement
                    && currentIndex != this.elementCount) {
                currentIndex++;
            } else {
                if (elementCount == 1) {
                    currentIndex++;
                }
            }

            if (currentIndex == this.elementCount && elementCount >= minimumElementCount.get(elementToProcess)) {
                isCompleted = true;
            }
        }
        lastElement = nextElement;
    }

    private String getUnvisitedElements() {
        StringBuilder unvisitedElementsStr = new StringBuilder();
        allElements.subList(currentIndex, this.elementCount).forEach(element -> {
            if (!elementOptionality.get(element)) {
                unvisitedElementsStr.append(xmlElementNameMap.get(element)).append(", ");
            }
        });
        String result = unvisitedElementsStr.toString();
        result = result.substring(0, result.length() - 2);
        return result;
    }

    private void updateUnvisitedElementsBasedOnPriorityOrder(RecordType fieldType) {
        HashMap<String, Integer> priorityOrder = DataUtils.getXsdSequencePriorityOrder(fieldType, true);
        for (String fieldName : priorityOrder.keySet()) {
            if (DataUtils.isFieldAnnotatedWithAny(fieldType, fieldName)) {
                anyAnnotatedFields.add(fieldName);
            }
        }
        this.allElements.addAll(priorityOrder.entrySet().stream()
                .sorted(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .toList());

        this.currentIndex = 0;
    }

    private void generateElementOptionalityMapIfNotPresent() {
        if (elementOptionality.isEmpty()) {
            if (!xmlElementInfo.isEmpty()) {
                allElements.forEach(element -> {
                    HashMap<String, ElementInfo> elementInfo = xmlElementInfo.peek();
                    if (elementInfo.containsKey(element)) {
                        ElementInfo info = elementInfo.get(element);
                        elementOptionality.put(element, info.minOccurs == 0);
                        remainingElementCount.put(element, (int) info.maxOccurs);
                        maxElementCount.put(element, (int) info.maxOccurs);
                        minimumElementCount.put(element, (int) info.minOccurs);
                    } else {
                        boolean isOptional = isFieldOptional(element);
                        int maxValue = getMaxValue(element);
                        elementOptionality.put(element, isOptional);
                        remainingElementCount.put(element, maxValue);
                        maxElementCount.put(element, maxValue);
                        minimumElementCount.put(element, isOptional ? 0 : 1);
                    }
                });
            } else {
                allElements.forEach(element -> {
                    boolean isOptional = isFieldOptional(element);
                    int maxValue = getMaxValue(element);
                    elementOptionality.put(element, isOptional);
                    remainingElementCount.put(element, maxValue);
                    maxElementCount.put(element, maxValue);
                    minimumElementCount.put(element, isOptional ? 0 : 1);
                });
            }
        }
    }

    private boolean isArrayField(String element) {
        if (fieldType == null) {
            return false;
        }
        String fieldName = xmlElementNameMap.getOrDefault(element, element);
        Field field = fieldType.getFields().get(fieldName);
        if (field == null) {
            return false;
        }
        return field.getFieldType().getTag() == TypeTags.ARRAY_TAG;
    }

    private int getMaxValue(String element) {
        boolean isArray = isArrayField(element);
        long maxOccurs = getElementMaxOccurs(element);
        if (maxOccurs > 0 && isArray) {
            return (int) maxOccurs;
        } else if (isArray) {
            return Integer.MAX_VALUE;
        }
        return 1;
    }

    private long getElementMaxOccurs(String element) {
        for (HashMap<String, ElementInfo> elementInfo : xmlElementInfo) {
            if (elementInfo.containsKey(element)) {
                return elementInfo.get(element).maxOccurs;
            }
        }
        return -1;
    }

    private boolean isFieldOptional(String element) {
        if (fieldType == null) {
            return false;
        }
        String fieldName = xmlElementNameMap.getOrDefault(element, element);
        Field field = fieldType.getFields().get(fieldName);
        if (field == null) {
            return false;
        }
        if (SymbolFlags.isFlagOn(field.getFlags(), SymbolFlags.OPTIONAL)) {
            return true;
        }
        return anyAnnotatedFields.contains(fieldName);
    }

    private void buildNestedSequenceElements(RecordType recordType) {
        if (recordType == null) {
            return;
        }
        BMap<BString, Object> annotations = recordType.getAnnotations();
        for (String xmlElementName : allElements) {
            String fieldName = xmlElementNameMap.getOrDefault(xmlElementName, xmlElementName);
            if (isFieldAnnotatedWithModuleSequence(annotations, fieldName)) {
                nestedSequenceFieldNames.add(xmlElementName);
                Field field = recordType.getFields().get(fieldName);
                if (field != null) {
                    Type fType = TypeUtils.getReferredType(field.getFieldType());
                    collectNestedSequenceElements(fType, nestedSequenceElements);
                }
            }
        }
    }

    private static boolean isFieldAnnotatedWithModuleSequence(BMap<BString, Object> annotations, String fieldName) {
        BString annotationKey = StringUtils.fromString(Constants.FIELD
                + fieldName.replaceAll(Constants.RECORD_FIELD_NAME_ESCAPE_CHAR_REGEX, "\\\\$0"));
        if (!annotations.containsKey(annotationKey)) {
            return false;
        }
        BMap<BString, Object> fieldAnnotation = (BMap<BString, Object>) annotations.get(annotationKey);
        for (BString key : fieldAnnotation.getKeys()) {
            String keyStr = key.getValue();
            if (keyStr.startsWith(Constants.MODULE_NAME) && keyStr.endsWith(Constants.SEQUENCE)) {
                return true;
            }
        }
        return false;
    }

    private static void collectNestedSequenceElements(Type type, Set<String> result) {
        RecordType recordType = null;
        if (type.getTag() == TypeTags.RECORD_TYPE_TAG) {
            recordType = (RecordType) type;
        } else if (type.getTag() == TypeTags.ARRAY_TAG) {
            Type elementType = TypeUtils.getReferredType(((ArrayType) type).getElementType());
            if (elementType.getTag() == TypeTags.RECORD_TYPE_TAG) {
                recordType = (RecordType) elementType;
            }
        }
        if (recordType == null) {
            return;
        }

        BMap<BString, Object> annotations = recordType.getAnnotations();
        HashMap<String, Integer> priorityOrder = DataUtils.getXsdSequencePriorityOrder(recordType, true);
        HashMap<String, String> elementNameMap = DataUtils.getXmlElementNameMap(recordType);

        // Build reverse map: fieldName -> xmlElementName
        HashMap<String, String> fieldToXmlName = new HashMap<>();
        elementNameMap.forEach((xmlName, fieldName) -> fieldToXmlName.put(fieldName, xmlName));

        for (String fieldName : priorityOrder.keySet()) {
            String xmlElementName = fieldToXmlName.getOrDefault(fieldName, fieldName);
            if (isFieldAnnotatedWithModuleSequence(annotations, fieldName)) {
                Field field = recordType.getFields().get(fieldName);
                if (field != null) {
                    collectNestedSequenceElements(TypeUtils.getReferredType(field.getFieldType()), result);
                }
            } else {
                result.add(xmlElementName);
            }
        }
    }

    private void reOrderElementNamesBasedOnTheNameAnnotation() {
        xmlElementNameMap.forEach((key, value) -> {
            if (allElements.contains(value)) {
                allElements.set(allElements.indexOf(value), key);
            }
        });
        allElements.forEach(element -> {
            if (!xmlElementNameMap.containsKey(element)) {
                xmlElementNameMap.put(element, element);
            }
        });
    }

    public long getMinOccurs() {
        return minOccurs;
    }

    public long getMaxOccurs() {
        return maxOccurs;
    }

    public String getFieldName() {
        return fieldName;
    }
}
