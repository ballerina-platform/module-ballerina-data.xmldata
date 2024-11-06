package io.ballerina.lib.data.xmldata.xml.xsd;

public interface ModelGroupInfo {
    public void updateOccurrences();
    public void validateMinOccurrences();
    public void validate();
    public void reset();

    public void visit(String element);
    public boolean isCompleted();
    public boolean isElementContains(String elementName);
}
