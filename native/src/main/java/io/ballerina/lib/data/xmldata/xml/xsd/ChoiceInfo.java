package io.ballerina.lib.data.xmldata.xml.xsd;

import io.ballerina.lib.data.xmldata.utils.Constants;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;
import java.util.Stack;

public class ChoiceInfo implements ModelGroupInfo {
    public String fieldName;
    public long minOccurs;
    public long maxOccurs;
    public int occurrences;
    public Set<String> allElements = new HashSet<>();
    public Set<String> visitedElements = new HashSet<>();


    public ChoiceInfo(String fieldName, BMap<BString, Object> element, RecordType fieldType) {
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
        this.occurrences = 1;
        this.allElements.addAll(fieldType.getFields().keySet());
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
        validateMinOccurrences();
    }

    @Override
    public void reset() {
        this.visitedElements.clear();
    }

    @Override
    public void visit(String element, boolean isStartElement) {
        this.visitedElements.add(element);
        if (this.visitedElements.containsAll(this.allElements)) {
            updateOccurrences();
            visitedElements.clear();
        }
    }

    @Override
    public boolean isCompleted() {
        return occurrences <= maxOccurs && occurrences >= minOccurs;
    }

    @Override
    public boolean isElementContains(String elementName) {
        return false;
    }

    @Override
    public boolean isMiddleOfModelGroup() {
        return false;
    }

    @Override
    public boolean isContainsAllRemaining(Stack<HashMap<String, ElementInfo>> elementInfoStack) {
        return false;
    }
}
