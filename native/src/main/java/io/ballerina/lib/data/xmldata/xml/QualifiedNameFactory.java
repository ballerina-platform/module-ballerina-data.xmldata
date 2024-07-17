package io.ballerina.lib.data.xmldata.xml;

public class QualifiedNameFactory {
    public static QualifiedName createQualifiedName(String namespaceURI, String localPart, String prefix,
                                                    QualifiedName.AttributeState attributeState,
                                                    boolean isSemantic) {
        if (isSemantic) {
            return new QualifiedNameSemantic(namespaceURI, localPart, prefix, attributeState);
        } else {
            return new QualifiedNameSyntax(namespaceURI, localPart, prefix, attributeState);
        }
    }

    public static QualifiedName createQualifiedName(String namespaceURI, String localPart, String prefix,
                                                    boolean isSemantic) {
        if (isSemantic) {
            return new QualifiedNameSemantic(namespaceURI, localPart, prefix);
        } else {
            return new QualifiedNameSyntax(namespaceURI, localPart, prefix);
        }
    }
}
