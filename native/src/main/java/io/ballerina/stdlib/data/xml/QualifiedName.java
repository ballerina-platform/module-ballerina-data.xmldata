package io.ballerina.stdlib.data.xml;

public class QualifiedName {
    private static final String NS_ANNOT_NOT_DEFINED = "$$ns_annot_not_defined$$";
    private String localPart;
    private String namespaceURI;
    private String prefix;

    public QualifiedName(String namespaceURI, String localPart, String prefix) {
        this.localPart = localPart;
        this.namespaceURI = namespaceURI;
        this.prefix = prefix;
    }

    public QualifiedName(String localPart) {
        this.localPart = localPart;
        this.namespaceURI = "";
        this.prefix = "";
    }

    public String getLocalPart() {
        return localPart;
    }

    public void setLocalPart(String localPart) {
        this.localPart = localPart;
    }

    public String getNamespaceURI() {
        return namespaceURI;
    }

    public String getPrefix() {
        return prefix;
    }

    @Override
    public int hashCode() {
        return localPart.hashCode();
    }

    @Override
    public boolean equals(Object objectToTest) {
        if (objectToTest == this) {
            return true;
        }

        if (objectToTest == null || !(objectToTest instanceof QualifiedName)) {
            return false;
        }

        QualifiedName qName = (QualifiedName) objectToTest;

        if (qName.namespaceURI.equals(NS_ANNOT_NOT_DEFINED) || namespaceURI.equals(NS_ANNOT_NOT_DEFINED)) {
            return localPart.equals(qName.localPart);
        }
        return localPart.equals(qName.localPart) && namespaceURI.equals(qName.namespaceURI) &&
                prefix.equals(qName.prefix);
    }
}
