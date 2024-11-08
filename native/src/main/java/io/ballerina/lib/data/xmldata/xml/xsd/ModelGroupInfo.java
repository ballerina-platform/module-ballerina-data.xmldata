package io.ballerina.lib.data.xmldata.xml.xsd;

import java.util.HashMap;
import java.util.Stack;

public interface ModelGroupInfo {
    public void updateOccurrences();
    public void validateMinOccurrences();
    public void validate();
    public void reset();

    public void visit(String element, boolean isStartElement);
    public boolean isCompleted();
    public boolean isElementContains(String elementName);
    public boolean isMiddleOfModelGroup();
    public boolean isContainsAllRemaining(Stack<HashMap<String, ElementInfo>> elementInfoStack);
}
