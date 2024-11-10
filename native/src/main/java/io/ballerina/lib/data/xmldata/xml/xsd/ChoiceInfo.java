package io.ballerina.lib.data.xmldata.xml.xsd;

import io.ballerina.lib.data.xmldata.utils.Constants;
import io.ballerina.lib.data.xmldata.utils.DataUtils;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

public class ChoiceInfo implements ModelGroupInfo {

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
    private final HashMap<String, String> xmlElementNameMap;
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
        this.allElements.addAll(DataUtils.getXmlElementNames(fieldType));
        this.xmlElementNameMap = DataUtils.getXmlElementNameMap(fieldType);
        reOrderElementNamesBasedOnTheNameAnnotation();
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
        generateElementOptionalityMapIfNotPresent();
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
        this.remainingElementCount.putAll(this.maxElementCount);
        this.lastElement = "";
    }

    @Override
    public void visit(String element, boolean isStartElement) {
        generateElementOptionalityMapIfNotPresent();
        if (isMiddleOfElement && isStartElement) {
            return;
        }

        isMiddleOfElement = isStartElement;

        if (isStartElement) {
            return;
        }

        if (visitedElements.contains(element)) {
            if (remainingElementCount.get(element) == 0) {
                throw new RuntimeException("Element " + xmlElementNameMap.get(element)
                        + " occurs more than the max allowed times");
            }
            remainingElementCount.put(element, remainingElementCount.get(element) - 1);
            return;
        }

        if (allElements.contains(element)) {
            this.visitedElements.add(element);
            lastElement = element;
            remainingElementCount.put(element, remainingElementCount.get(element) - 1);
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
        if (element.equals(lastElement) && remainingElementCount.get(element) > 0) {
            return false;
        }
        return !isMiddleOfElement && !visitedElements.isEmpty();
    }

    private void validateCompletedChoice() {
        int elementCount = maxElementCount.get(lastElement) - remainingElementCount.get(lastElement);
        if (elementCount < minimumElementCount.get(lastElement)) {
            return;
        }
        if (visitedElements.size() > 1) {
            throw new RuntimeException("Only one element in " + fieldName + " should be present");
        }
        updateOccurrences();
    }

    public void validateMinOccurrences() {
        if (this.occurrences < this.minOccurs) {
            throw new RuntimeException(fieldName + " Element occurs less than the min required times");
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

    private void reOrderElementNamesBasedOnTheNameAnnotation() {
        allElements.forEach(element -> {
            if (!xmlElementNameMap.containsKey(element)) {
                xmlElementNameMap.put(element, element);
            }
        });
    }
}
