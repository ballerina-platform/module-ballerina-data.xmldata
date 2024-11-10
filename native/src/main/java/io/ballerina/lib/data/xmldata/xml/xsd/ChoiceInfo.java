package io.ballerina.lib.data.xmldata.xml.xsd;

import io.ballerina.lib.data.xmldata.utils.Constants;
import io.ballerina.lib.data.xmldata.utils.DataUtils;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;
import java.util.Stack;

public class ChoiceInfo implements ModelGroupInfo {

    private final Stack<HashMap<String, ElementInfo>> xmlElementInfo;
    public String fieldName;
    public long minOccurs;
    public long maxOccurs;
    public int occurrences;
    public final Set<String> allElements = new HashSet<>();
    public final Set<String> visitedElements = new HashSet<>();
    private final HashMap<String, String> xmlElementNameMap = new HashMap<>();
    private boolean isMiddleOfElement = false;


    public ChoiceInfo(String fieldName, BMap<BString, Object> element, RecordType fieldType,
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
        this.allElements.addAll(DataUtils.getXmlElementNames(fieldType, xmlElementNameMap));
        this.xmlElementInfo = xmlElementInfo;
    }

    public void updateOccurrences() {
        this.occurrences++;
        if (occurrences > maxOccurs) {
            throw new RuntimeException(fieldName + " Element occurs more than the max allowed times");
        }
    }

    @Override
    public void validate() {
        validateCompletedChoice();
        markOtherElementsAsOptional();
        reset();
    }

    private void markOtherElementsAsOptional() {
        if (!xmlElementInfo.isEmpty()) {
            HashMap<String, ElementInfo> elementInfo = xmlElementInfo.peek();
            for (String element : allElements) {
                if (!visitedElements.contains(element)) {
                    ElementInfo eleInfo = elementInfo.get(element);
                    if (eleInfo != null) {
                        eleInfo.isInsideChoice = true;
                    }
                }
            }
        }
    }

    @Override
    public void reset() {
        this.visitedElements.clear();
        isMiddleOfElement = false;
    }

    @Override
    public void visit(String element, boolean isStartElement) {
        if (isMiddleOfElement && isStartElement) {
            return;
        }

        isMiddleOfElement = isStartElement;

        if (isStartElement) {
            return;
        }

        if (allElements.contains(element)) {
            this.visitedElements.add(element);
            return;
        }

        throw new RuntimeException("Unexpected element " + xmlElementNameMap.get(element) + " found in " + fieldName);
    }

    @Override
    public int getOccurences() {
        return occurrences;
    }

    @Override
    public boolean isElementContains(String elementName) {
        return allElements.contains(elementName);
    }

    @Override
    public boolean isMiddleOfModelGroup() {
        return isMiddleOfElement;
    }

    @Override
    public boolean predictStartNewModelGroup(String element) {
        return !visitedElements.isEmpty() && !isMiddleOfElement;
    }

    private void validateCompletedChoice() {
        if (visitedElements.size() != 1) {
            throw new RuntimeException("Only one element in " + fieldName + " should be present");
        }
        updateOccurrences();
    }

    public void validateMinOccurrences() {
        if (this.occurrences < this.minOccurs) {
            throw new RuntimeException(fieldName + " Element occurs less than the min required times");
        }
    }
}
