package io.ballerina.lib.data.xmldata.xml.xsd;

public interface ModelGroupInfo {
    void updateOccurrences();
    void validate();
    void reset();

    void visit(String element, boolean isStartElement);
    int getOccurences();
    boolean isElementContains(String elementName);
    boolean isMiddleOfModelGroup();
    boolean predictStartNewModelGroup(String element);
    void validateMinOccurrences();
}
