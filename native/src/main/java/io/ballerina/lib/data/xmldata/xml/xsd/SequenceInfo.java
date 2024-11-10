package io.ballerina.lib.data.xmldata.xml.xsd;

import io.ballerina.lib.data.xmldata.utils.Constants;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

public class SequenceInfo implements ModelGroupInfo {
    public String fieldName;
    public long minOccurs;
    public long maxOccurs;
    public int occurrences;

    // TODO: Update to a hashset<String>
    private final Set<String> unvisitedElements = new HashSet<>();
    private final Set<String> visitedElements = new HashSet<>();
    private final Set<String> allElements = new HashSet<>();
    private final Map<String, Long> elementPriorityOrder = new HashMap<>();
    private boolean isCompleted = false;
    private boolean isMiddleOfElement = false;
    private long currentPriority = -1L;
    private final Stack<HashMap<String, ElementInfo>> xmlElementInfo;
    private final HashMap<String, String> xmlElementnameMap = new HashMap<>();

    public SequenceInfo(String fieldName, BMap<BString, Object> element, RecordType fieldType,
                        Stack<HashMap<String, ElementInfo>> xmlElementInfo) {
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

        // TODO: Name Annotation not encountered
        this.allElements.addAll(getXmlElementNames(fieldType));
        this.unvisitedElements.addAll(this.allElements);
        updatePriorityOrder(fieldType);
        this.xmlElementInfo = xmlElementInfo;
    }

    private Collection<String> getXmlElementNames(RecordType fieldType) {
        HashSet<String> elementNames = new HashSet<>(fieldType.getFields().keySet());
        BMap<BString, Object> annotations = fieldType.getAnnotations();
        for (BString annotationKey : annotations.getKeys()) {
            String key = annotationKey.getValue();
            if (key.contains(Constants.FIELD)) {
                String fieldName = key.split(Constants.FIELD_REGEX)[1].replaceAll("\\\\", "");
                Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
                for (BString fieldAnnotationKey : fieldAnnotation.keySet()) {
                    updateFieldSetWithName(fieldAnnotation, elementNames, fieldAnnotationKey, fieldName);
                }
            }
        }
        return elementNames;
    }

    private void updateFieldSetWithName(Map<BString, Object> fieldAnnotation, Set<String> elementNames,
                                             BString fieldAnnotationKey, String fieldName) {
        String fieldAnnotationKeyStr = fieldAnnotationKey.getValue();
        if (fieldAnnotationKeyStr.startsWith(Constants.MODULE_NAME)) {
            if (fieldAnnotationKeyStr.endsWith(Constants.NAME)) {
                BMap<BString, Object> fieldAnnotationValue =
                        (BMap<BString, Object>) fieldAnnotation.get(fieldAnnotationKey);
                String xmlElementName = StringUtils.getStringValue(fieldAnnotationValue
                        .getStringValue(Constants.VALUE));
                elementNames.remove(fieldName);
                elementNames.add(xmlElementName);
                xmlElementnameMap.put(xmlElementName, fieldName);
                return;
            }
            xmlElementnameMap.put(fieldName, fieldName);
        }
    }

    private void updatePriorityOrder(RecordType fieldType) {
        BMap<BString, Object> annotations = fieldType.getAnnotations();
        for (BString annotationKey : annotations.getKeys()) {
            String key = annotationKey.getValue();
            if (key.contains(Constants.FIELD)) {
                String fieldName = key.split(Constants.FIELD_REGEX)[1].replaceAll("\\\\", "");
                Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
                for (BString fieldAnnotationKey : fieldAnnotation.keySet()) {
                    String fieldAnnotationKeyStr = fieldAnnotationKey.getValue();
                    if (fieldAnnotationKeyStr.startsWith(Constants.MODULE_NAME)) {
                        if (fieldAnnotationKeyStr.endsWith(Constants.ORDER)) {
                            BMap<BString, Object> fieldAnnotationValue =
                                    (BMap<BString, Object>) fieldAnnotation.get(fieldAnnotationKey);
                            this.elementPriorityOrder.put(fieldName, fieldAnnotationValue.getIntValue(Constants.VALUE));
                        }
                    }
                }
            }
        }
    }

    public void updateOccurrences() {
        this.occurrences++;
        if (this.occurrences > this.maxOccurs) {
            throw new RuntimeException(fieldName + " Element occurs more than the max allowed times");
        }
    }

    public void validateMinOccurrences() {
        if (this.occurrences < this.minOccurs) {
            throw new RuntimeException(fieldName + " Element occurs less than the min required times");
        }
    }

    @Override
    public void validate() {
        validateCompletedSequences();
        if (!isCompleted && !containsAllOptionalElements(this.xmlElementInfo)) {
            throw new RuntimeException("Element " + getUnvisitedElements() + " not found in " + fieldName);
        }
        validateMinOccurrences();
        reset();
    }

    @Override
    public void reset() {
        this.unvisitedElements.addAll(allElements);
        this.visitedElements.clear();
        this.currentPriority = -1L;
        this.isCompleted = false;
        this.isMiddleOfElement = false;
    }

    @Override
    public void visit(String element, boolean isStartElement) {
        if (isMiddleOfElement && isStartElement) {
            return;
        }

        isMiddleOfElement = isStartElement;
        compareSequencePriorityOrder(element);

        if (isStartElement) {
            isCompleted = false;
            return;
        }

        if (this.unvisitedElements.contains(element)) {
            isMiddleOfElement = false;
            isCompleted = false;
            this.unvisitedElements.remove(element);
            this.visitedElements.add(element);
            return;
        }

        if (this.visitedElements.contains(element)) {
            return;
        }
        throw new RuntimeException("Unexpected element " + xmlElementnameMap.get(element) + " found in " + fieldName);
    }

    @Override
    public int getOccurences() {
        return this.occurrences;
    }

    @Override
    public boolean isElementContains(String elementName) {
        return this.allElements.contains(elementName);
    }

    @Override
    public boolean isMiddleOfModelGroup() {
        return isMiddleOfElement;
    }

    private void validateCompletedSequences() {
        if (unvisitedElements.isEmpty()) {
            isCompleted = true;
            updateOccurrences();
        }
    }

    private void compareSequencePriorityOrder(String element) {
        Long elementPriority = elementPriorityOrder.get(element);
        if (elementPriority != null) {
            if (elementPriority < currentPriority) {
                throw new RuntimeException("Element " + xmlElementnameMap.get(element) +
                        " is not in the correct order in " + fieldName);
            }
            currentPriority = elementPriority;
        }
    }

    //TODO: Check
    public boolean checkAndStartNewModelGroup(String element) {
        if (!isElementContains(element)) {
            return false;
        }
        Long elementPriority = elementPriorityOrder.get(element);
        if (elementPriority != null) {
            // TODO: Priority orders should be start from 1.
            return !isMiddleOfElement && elementPriority < currentPriority
                    && elementPriority == 1;
        }
        return false;
    }

    private boolean containsAllOptionalElements(Stack<HashMap<String, ElementInfo>> elementInfoStack) {
        if (elementInfoStack.isEmpty()) {
            return false;
        }

        HashMap<String, ElementInfo> elementInfo = elementInfoStack.peek();
        Set<String> unvisitedElementsTemp = new HashSet<>(unvisitedElements);
        unvisitedElementsTemp.forEach(element -> {
            if (elementInfo.containsKey(element)) {
                ElementInfo elem = elementInfo.get(element);
                if (elem.minOccurs == 0) {
                    unvisitedElements.remove(element);
                }
            }
        });
        if (unvisitedElements.isEmpty()) {
            updateOccurrences();
            return true;
        }
        return false;
    }

    private String getUnvisitedElements() {
        StringBuilder unvisitedElementsStr = new StringBuilder();
        unvisitedElements.forEach(element -> unvisitedElementsStr.append(xmlElementnameMap.get(element)).append(", "));
        String result = unvisitedElementsStr.toString();
        result = result.substring(0, result.length() - 2);
        return result;
    }
}
