package io.ballerina.lib.data.xmldata.xml.xsd;

import io.ballerina.lib.data.xmldata.utils.Constants;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class SequenceInfo implements ModelGroupInfo {
    public String fieldName;
    public long minOccurs;
    public long maxOccurs;
    public int occurrences;

    // TODO: Update to a hashset<String>
    private Set<String> unvisitedElements = new HashSet<>();
    private Set<String> visitedElements = new HashSet<>();
    private Set<String> allElements = new HashSet<>();
    private Map<String, Long> elementPriorityOrder = new HashMap<>();
    private boolean isCompleted = false;
    private boolean isMiddleOfElement = false;
    private long currentPriority = -1L;


    public SequenceInfo(String fieldName, BMap<BString, Object> element, RecordType fieldType) {
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
        this.allElements.addAll(fieldType.getFields().keySet());
        this.unvisitedElements.addAll(fieldType.getFields().keySet());
        updatePriorityOrder(fieldType);
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
                        BMap<BString, Object> fieldAnnotationValue = null;
                        if (fieldAnnotationKeyStr.endsWith(Constants.ORDER)) {
                            fieldAnnotationValue = (BMap<BString, Object>) fieldAnnotation.get(fieldAnnotationKey);
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
        if (!isCompleted) {
            throw new RuntimeException("Element " + unvisitedElements.iterator().next() + " not found in " + fieldName);
        }
        validateMinOccurrences();
    }

    @Override
    public void reset() {
        this.unvisitedElements.addAll(allElements);
        this.visitedElements.clear();
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

            //TODO: Remove unvisitedElements variable and get it using set substraction
            this.unvisitedElements.remove(element);
            this.visitedElements.add(element);
            isCompletedSequences(element);
            return;
        }
        throw new RuntimeException("Unexpected element " + element + " found in " + fieldName);
    }

    private void compareSequencePriorityOrder(String element) {
        Long elementPriority = elementPriorityOrder.get(element);
        if (elementPriority != null) {
            if (elementPriority < currentPriority) {
                throw new RuntimeException("Element " + element + " is not in the correct order in " + fieldName);
            }
            currentPriority = elementPriority;
        }
    }

    @Override
    public boolean isCompleted() {
        return this.isCompleted;
    }

    @Override
    public boolean isElementContains(String elementName) {
        return this.allElements.contains(elementName);
    }

    @Override
    public boolean isMiddleOfModelGroup() {
        return isMiddleOfElement;
    }

    private void isCompletedSequences(String element) {
        if (unvisitedElements.isEmpty() && visitedElements.contains(element)) {
            isCompleted = true;
            reset();
            updateOccurrences();
        }
    }
}
