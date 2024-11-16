package io.ballerina.lib.data.xmldata.xml.xsd;

import io.ballerina.lib.data.xmldata.utils.Constants;
import io.ballerina.lib.data.xmldata.utils.DataUtils;
import io.ballerina.lib.data.xmldata.utils.DiagnosticErrorCode;
import io.ballerina.lib.data.xmldata.utils.DiagnosticLog;
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
    public final Set<String> containElements = new HashSet<>();
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
        return allElements.contains(elementName);
    }

    @Override
    public boolean isMiddleOfModelGroup() {
        return isMiddleOfElement;
    }

    @Override
    public boolean predictStartNewModelGroup(String element) {
        generateElementOptionalityMapIfNotPresent();
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

    private void reOrderElementNamesBasedOnTheNameAnnotation() {
        allElements.forEach(element -> {
            if (!xmlElementNameMap.containsKey(element)) {
                xmlElementNameMap.put(element, element);
            }
        });
    }
}
