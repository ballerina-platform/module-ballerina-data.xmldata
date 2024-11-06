package io.ballerina.lib.data.xmldata.xml.xsd;

import io.ballerina.lib.data.xmldata.utils.Constants;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.HashSet;
import java.util.Set;

public class SequenceInfo implements ModelGroupInfo {
    public String fieldName;
    public long minOccurs;
    public long maxOccurs;
    public int occurrences;

    // TODO: Update to a hashset<String>
    public Set<String> unvisitedElements = new HashSet<>();
    public Set<String> visitedElements = new HashSet<>();
    public Set<String> allElements = new HashSet<>();


    public SequenceInfo(String fieldName, BMap<BString, Object> element, RecordType fieldType) {
        this.fieldName = fieldName;
        if (element.containsKey(Constants.MIN_OCCURS)) {
            this.minOccurs = element.getIntValue(Constants.MIN_OCCURS);
        } else {
            this.minOccurs = 1;
        }

        if (element.containsKey(Constants.MAX_OCCURS)) {
            this.minOccurs = element.getIntValue(Constants.MAX_OCCURS);
        } else {
            this.maxOccurs = Math.max(this.minOccurs, 1);
        }
        this.occurrences = 0;

        // TODO: Name Annotation not encountered
        this.allElements.addAll(fieldType.getFields().keySet());
        this.unvisitedElements.addAll(fieldType.getFields().keySet());
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
        if (unvisitedElements.size() > 0) {
            throw new RuntimeException("Element " + unvisitedElements.iterator().next() + " not found in " + fieldName);
        }
    }

    @Override
    public void reset() {
        this.unvisitedElements.addAll(allElements);
        this.visitedElements.clear();
    }

    @Override
    public void visit(String element) {
        if (this.unvisitedElements.contains(element)) {
            this.unvisitedElements.remove(element);
            this.visitedElements.add(element);
        } else {
            if (unvisitedElements.isEmpty() && visitedElements.contains(element)) {
                reset();
                updateOccurrences();
                visitedElements.add(element);
                return;
            }
            throw new RuntimeException("Unexpected element " + element + " found in " + fieldName);
        }
    }

    @Override
    public boolean isCompleted() {
        return this.unvisitedElements.isEmpty();
    }

    @Override
    public boolean isElementContains(String elementName) {
        return this.allElements.contains(elementName);
    }
}
