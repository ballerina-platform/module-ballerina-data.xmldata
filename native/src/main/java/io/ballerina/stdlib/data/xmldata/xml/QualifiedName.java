/*
 * Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.data.xmldata.xml;

/**
 * Represents a qualified name.
 *
 * @since 0.1.0
 */
public class QualifiedName {
    public static final String NS_ANNOT_NOT_DEFINED = "$$ns_annot_not_defined$$";
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
