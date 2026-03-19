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
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

/**
 * Represent xsd choice.
 *
 * @since 1.1.0
 */
public class ChoiceInfo implements ModelGroupInfo {

    private static final String SPECIAL_CHAR_REGEX = "\\\\$0";

    private final Stack<HashMap<String, ElementInfo>> xmlElementInfo;
    private final Map<String, Integer> remainingElementCount = new HashMap<>();
    private final Map<String, Integer> minimumElementCount = new HashMap<>();
    private final Map<String, Integer> maxElementCount = new HashMap<>();
    private final Map<String, Boolean> elementOptionality = new HashMap<>();
    public String fieldName;
    public long minOccurs;
    public long maxOccurs;
    public int occurrences;
    String lastElement = "";
    public final Set<String> allElements = new HashSet<>();
    public final Set<String> visitedElements = new HashSet<>();
    public final Set<String> containElements = new HashSet<>();
    private final HashMap<String, String> xmlElementNameMap;
    private boolean isMiddleOfElement = false;
    private final boolean isArrayField;
    private final Set<String> nestedGroupElements = new HashSet<>();
    private final Set<String> nestedGroupFieldNames = new HashSet<>();
    private final Set<String> usedNestedGroupFieldNames = new HashSet<>();


    public ChoiceInfo(String fieldName, BMap<BString, Object> element, RecordType fieldType,
                      Stack<HashMap<String, ElementInfo>> xmlElementInfo, boolean isArrayField) {
        this.fieldName = fieldName;
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
        this.allElements.addAll(DataUtils.getXmlElementNames(fieldType));
        this.xmlElementNameMap = DataUtils.getXmlElementNameMap(fieldType);
        reOrderElementNamesBasedOnTheNameAnnotation();
        this.xmlElementInfo = xmlElementInfo;
        this.isArrayField = isArrayField;
        buildNestedGroupElements(fieldType);
        if (isArrayField) {
            initElementCountsFromFieldType(fieldType);
        }
    }

    private void initElementCountsFromFieldType(RecordType fieldType) {
        HashMap<String, ElementInfo> elementAnnotations = DataUtils.getFieldNamesWithElementGroupAnnotations(fieldType);
        allElements.forEach(element -> {
            ElementInfo info = elementAnnotations.get(element);
            if (info != null) {
                elementOptionality.put(element, info.minOccurs == 0);
                remainingElementCount.put(element, (int) info.maxOccurs);
                maxElementCount.put(element, (int) info.maxOccurs);
                minimumElementCount.put(element, (int) info.minOccurs);
            } else {
                elementOptionality.put(element, false);
                remainingElementCount.put(element, 1);
                maxElementCount.put(element, 1);
                minimumElementCount.put(element, 1);
            }
        });
    }

    public void updateOccurrences() {
        this.occurrences++;
        if (occurrences > maxOccurs) {
            throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_MORE_THAN_MAX_ALLOWED_TIMES, fieldName);
        }
    }

    @Override
    public void validate() {
        generateElementOptionalityMapIfNotPresent();
        markOtherElementsAsOptional();
        reset();
    }

    private void markOtherElementsAsOptional() {
        if (!allElements.isEmpty()) {
            HashMap<String, ElementInfo> elementInfo = xmlElementInfo.peek();
            for (String element : allElements) {
                if (!containElements.contains(element)) {
                    ElementInfo eleInfo = elementInfo.get(element);
                    if (eleInfo != null) {
                        eleInfo.isInsideChoice = true;
                    }
                }
            }
        }
    }

    private void reset() {
        this.visitedElements.clear();
        isMiddleOfElement = false;
        this.remainingElementCount.putAll(this.maxElementCount);
        this.lastElement = "";
        this.containElements.clear();
    }

    @Override
    public void visit(String element, boolean isStartElement) {
        generateElementOptionalityMapIfNotPresent();
        if (isMiddleOfElement && isStartElement) {
            return;
        }

        if (nestedGroupElements.contains(element)) {
            return;
        }

        isMiddleOfElement = isStartElement;

        if (isStartElement) {
            return;
        }

        remainingElementCount.put(element, remainingElementCount.get(element) - 1);
        containElements.add(element);

        if (visitedElements.contains(element)) {
            if (remainingElementCount.get(element) == 0) {
                remainingElementCount.putAll(maxElementCount);
                visitedElements.remove(element);
            }
            return;
        }

        if (allElements.contains(element)) {
            int count = maxElementCount.get(element) - remainingElementCount.get(element);
            if (count >= minimumElementCount.get(element)) {
                this.visitedElements.add(element);
                updateOccurrences();
            }

            if (remainingElementCount.get(element) == 0) {
                remainingElementCount.putAll(maxElementCount);
                visitedElements.remove(element);
            }
            return;
        }

        throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_ELEMENT_FOUND, xmlElementNameMap.get(element), fieldName);
    }

    @Override
    public boolean isElementContains(String elementName) {
        return allElements.contains(elementName) || nestedGroupElements.contains(elementName);
    }

    @Override
    public void notifyNestedGroupCompleted(String completedFieldName) {
        if (completedFieldName == null) {
            this.occurrences = (int) this.minOccurs;
            return;
        }
        String xmlElementName = getXmlElementNameFromFieldName(completedFieldName);
        if (!nestedGroupFieldNames.contains(xmlElementName)) {
            return;
        }
        usedNestedGroupFieldNames.add(xmlElementName);
        generateElementOptionalityMapIfNotPresent();
        Integer remaining = remainingElementCount.get(xmlElementName);
        if (remaining == null) {
            remainingElementCount.put(xmlElementName, 1);
            maxElementCount.put(xmlElementName, 1);
            minimumElementCount.put(xmlElementName, 1);
            remaining = 1;
        }
        remainingElementCount.put(xmlElementName, remaining - 1);
        containElements.add(xmlElementName);
        if (!visitedElements.contains(xmlElementName)) {
            int count = maxElementCount.get(xmlElementName) - remainingElementCount.get(xmlElementName);
            if (count >= minimumElementCount.get(xmlElementName)) {
                visitedElements.add(xmlElementName);
                updateOccurrences();
            }
        }
    }

    private String getXmlElementNameFromFieldName(String fieldName) {
        for (Map.Entry<String, String> entry : xmlElementNameMap.entrySet()) {
            if (entry.getValue().equals(fieldName)) {
                return entry.getKey();
            }
        }
        return fieldName;
    }

    @Override
    public boolean isMiddleOfModelGroup() {
        return isMiddleOfElement;
    }

    @Override
    public boolean predictStartNewModelGroup(String element) {
        generateElementOptionalityMapIfNotPresent();
        if (!isMiddleOfElement && isArrayField && isElementContains(element) && !containElements.isEmpty()
                && maxOccurs > 1) {
            Integer remaining = remainingElementCount.get(element);
            Integer max = maxElementCount.get(element);
            return remaining != null && max != null && remaining.equals(max);
        }
        return !isMiddleOfElement && !isElementContains(element);
    }

    public void validateMinOccurrences() {
        if (this.occurrences < this.minOccurs) {
            throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_LESS_THAN_MIN_REQUIRED_TIMES, fieldName);
        }
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
                        elementOptionality.put(element, false);
                        remainingElementCount.put(element, 1);
                        maxElementCount.put(element, 1);
                        minimumElementCount.put(element, 1);
                    }
                });
            } else {
                allElements.forEach(element -> {
                    elementOptionality.put(element, false);
                    remainingElementCount.put(element, 1);
                    maxElementCount.put(element, 1);
                    minimumElementCount.put(element, 1);
                });
            }
        }
    }

    private void buildNestedGroupElements(RecordType recordType) {
        BMap<BString, Object> annotations = recordType.getAnnotations();
        for (String xmlElementName : allElements) {
            String fName = xmlElementNameMap.getOrDefault(xmlElementName, xmlElementName);
            if (isFieldAnnotatedWithModuleSequence(annotations, fName)) {
                nestedGroupFieldNames.add(xmlElementName);
                Field field = recordType.getFields().get(fName);
                if (field != null) {
                    Type fType = TypeUtils.getReferredType(field.getFieldType());
                    collectNestedGroupElements(fType, nestedGroupElements, true);
                }
            } else if (isFieldAnnotatedWithModuleChoice(annotations, fName)) {
                nestedGroupFieldNames.add(xmlElementName);
                Field field = recordType.getFields().get(fName);
                if (field != null) {
                    Type fType = TypeUtils.getReferredType(field.getFieldType());
                    collectNestedGroupElements(fType, nestedGroupElements, false);
                }
            }
        }
    }

    private static void collectNestedGroupElements(Type type, Set<String> result, boolean isSequence) {
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
        HashMap<String, String> elementNameMap = DataUtils.getXmlElementNameMap(recordType);
        HashMap<String, String> fieldToXmlName = new HashMap<>();
        elementNameMap.forEach((xmlName, fieldName) -> fieldToXmlName.put(fieldName, xmlName));

        Collection<String> fieldNames;
        if (isSequence) {
            fieldNames = DataUtils.getXsdSequencePriorityOrder(recordType, true).keySet();
        } else {
            fieldNames = recordType.getFields().keySet();
        }

        for (String fieldName : fieldNames) {
            String xmlElementName = fieldToXmlName.getOrDefault(fieldName, fieldName);
            if (isFieldAnnotatedWithModuleSequence(annotations, fieldName)) {
                Field field = recordType.getFields().get(fieldName);
                if (field != null) {
                    collectNestedGroupElements(TypeUtils.getReferredType(field.getFieldType()), result, true);
                }
            } else if (isFieldAnnotatedWithModuleChoice(annotations, fieldName)) {
                Field field = recordType.getFields().get(fieldName);
                if (field != null) {
                    collectNestedGroupElements(TypeUtils.getReferredType(field.getFieldType()), result, false);
                }
            } else {
                result.add(xmlElementName);
            }
        }
    }

    private static boolean isFieldAnnotatedWithModuleSequence(BMap<BString, Object> annotations, String fieldName) {
        BString annotationKey = StringUtils.fromString(Constants.FIELD
                + fieldName.replaceAll(Constants.RECORD_FIELD_NAME_ESCAPE_CHAR_REGEX, SPECIAL_CHAR_REGEX));
        BMap<BString, Object> fieldAnnotation = (BMap<BString, Object>) annotations.get(annotationKey);
        if (fieldAnnotation == null) {
            return false;
        }
        for (BString key : fieldAnnotation.getKeys()) {
            String keyStr = key.getValue();
            if (keyStr.startsWith(Constants.MODULE_NAME) && keyStr.endsWith(Constants.SEQUENCE)) {
                return true;
            }
        }
        return false;
    }

    private static boolean isFieldAnnotatedWithModuleChoice(BMap<BString, Object> annotations, String fieldName) {
        BString annotationKey = StringUtils.fromString(Constants.FIELD
                + fieldName.replaceAll(Constants.RECORD_FIELD_NAME_ESCAPE_CHAR_REGEX, SPECIAL_CHAR_REGEX));
        BMap<BString, Object> fieldAnnotation = (BMap<BString, Object>) annotations.get(annotationKey);
        if (fieldAnnotation == null) {
            return false;
        }
        for (BString key : fieldAnnotation.getKeys()) {
            String keyStr = key.getValue();
            if (keyStr.startsWith(Constants.MODULE_NAME) && keyStr.endsWith(Constants.CHOICE)) {
                return true;
            }
        }
        return false;
    }

    private void reOrderElementNamesBasedOnTheNameAnnotation() {
        allElements.forEach(element -> {
            if (!xmlElementNameMap.containsKey(element)) {
                xmlElementNameMap.put(element, element);
            }
        });
    }

    public boolean isUnusedNestedGroupField(String fieldName) {
        String xmlName = getXmlElementNameFromFieldName(fieldName);
        return nestedGroupFieldNames.contains(xmlName) && !usedNestedGroupFieldNames.contains(xmlName);
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
