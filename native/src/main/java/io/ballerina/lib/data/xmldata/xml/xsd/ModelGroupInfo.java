package io.ballerina.lib.data.xmldata.xml.xsd;

public interface ModelGroupInfo {
    void validate();
    void visit(String element, boolean isStartElement);
    boolean isElementContains(String elementName);
    boolean isMiddleOfModelGroup();
    boolean predictStartNewModelGroup(String element);
    void validateMinOccurrences();
}
