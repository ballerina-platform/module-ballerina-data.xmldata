package io.ballerina.lib.data.xmldata.xml;

import io.ballerina.lib.data.xmldata.utils.Constants;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class QualifiedNameMap<V> {
    private final Map<QualifiedName, V> members;
    private final Map<String, List<QualifiedName>> stringToQNameMap;

    public QualifiedNameMap(Map<QualifiedName, V> fields) {
        this.members = fields;
        this.stringToQNameMap = getStringToQNamesMap(fields.keySet());
    }

    public Map<QualifiedName, V> getMembers() {
        return members;
    }

    public V remove(QualifiedName qName) {
        V field = members.remove(qName);
        if (field == null) {
            Map<String, List<QualifiedName>> fields = stringToQNameMap;
            String localName = qName.getLocalPart();
            if (!fields.containsKey(localName)) {
                return null;
            }

            List<QualifiedName> qNames = fields.get(localName);
            for (QualifiedName qualifiedName : fields.get(localName)) {
                if (isSameNamespace(qualifiedName, qName)
                        && isSameAttributeFlag(qualifiedName.getAttributeState(), qName.getAttributeState())) {
                    field = this.members.remove(qualifiedName);
                    qNames.remove(qualifiedName);
                    break;
                }
            }

            if (qNames.isEmpty()) {
                fields.remove(localName);
            }
        }
        return field;
    }

    public boolean contains(QualifiedName qName) {
        if (members.containsKey(qName)) {
            return true;
        }

        String localName = qName.getLocalPart();
        if (!stringToQNameMap.containsKey(localName)) {
            return false;
        }
        for (QualifiedName qualifiedName : stringToQNameMap.get(localName)) {
            if (isSameNamespace(qualifiedName, qName)
                    && isSameAttributeFlag(qualifiedName.getAttributeState(), qName.getAttributeState())) {
                return true;
            }
        }
        return false;
    }

    private boolean isSameNamespace(QualifiedName q1, QualifiedName q2) {
        String ns1 = q1.getNamespaceURI();
        String ns2 = q2.getNamespaceURI();
        return  (ns1.equals(ns2) && q1.getPrefix().equals(q2.getPrefix()))
                || ns1.equals(Constants.NS_ANNOT_NOT_DEFINED) || ns2.equals(Constants.NS_ANNOT_NOT_DEFINED);
    }

    private boolean isSameAttributeFlag(QualifiedName.AttributeState flag1, QualifiedName.AttributeState flag2) {
        return (flag1 == QualifiedName.AttributeState.NOT_DEFINED
                || flag2 == QualifiedName.AttributeState.NOT_DEFINED) || (flag1.equals(flag2));
    }

    public boolean contains(String localName) {
        return stringToQNameMap.containsKey(localName);
    }

    public void put(QualifiedName qName, V value) {
        members.put(qName, value);
        String localName = qName.getLocalPart();
        if (stringToQNameMap.containsKey(localName)) {
            stringToQNameMap.get(localName).add(qName);
        } else {
            List<QualifiedName> qNames = new ArrayList<>();
            qNames.add(qName);
            stringToQNameMap.put(localName, qNames);
        }
    }

    public V get(QualifiedName qName) {
        if (members.containsKey(qName)) {
            return members.get(qName);
        }

        String localName = qName.getLocalPart();
        if (!stringToQNameMap.containsKey(localName)) {
            return null;
        }
        for (QualifiedName qualifiedName : stringToQNameMap.get(localName)) {
            if (isSameNamespace(qualifiedName, qName)
                    && isSameAttributeFlag(qualifiedName.getAttributeState(), qName.getAttributeState())) {
                return members.get(qualifiedName);
            }
        }
        return null;
    }

    public V getOrDefault(QualifiedName qName, V defaultValue) {
        V value = get(qName);
        return value != null ? value : defaultValue;
    }

    public boolean isEmpty() {
        return members.isEmpty();
    }

    public QualifiedName getMatchedQualifiedName(QualifiedName elementQName) {
        if (members.containsKey(elementQName)) {
            return elementQName;
        }

        String localName = elementQName.getLocalPart();
        if (!stringToQNameMap.containsKey(localName)) {
            return null;
        }
        for (QualifiedName qualifiedName : stringToQNameMap.get(localName)) {
            if (isSameNamespace(qualifiedName, elementQName)
                    && isSameAttributeFlag(qualifiedName.getAttributeState(), elementQName.getAttributeState())) {
                return qualifiedName;
            }
        }
        return null;
    }

    public void clear() {
        members.clear();
        stringToQNameMap.clear();
    }

    private Map<String, List<QualifiedName>> getStringToQNamesMap(Set<QualifiedName> fieldQNames) {
        Map<String, List<QualifiedName>> fields = new HashMap<>();
        for (QualifiedName qName : fieldQNames) {
            String localName = qName.getLocalPart();
            if (fields.containsKey(localName)) {
                fields.get(localName).add(qName);
            } else {
                List<QualifiedName> qNames = new ArrayList<>();
                qNames.add(qName);
                fields.put(localName, qNames);
            }
        }
        return fields;
    }
}
