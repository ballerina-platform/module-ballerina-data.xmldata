/*
 * Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
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

package io.ballerina.lib.data.xmldata.xml;

/**
 * Represents a syntactic qualified name.
 *
 * @since 0.1.4
 */
public class QualifiedNameSyntax extends QualifiedName {

    public QualifiedNameSyntax(String namespaceURI, String localPart, String prefix, AttributeState attributeState) {
        super(namespaceURI, localPart, prefix, attributeState);
    }

    public QualifiedNameSyntax(String namespaceURI, String localPart, String prefix) {
        super(namespaceURI, localPart, prefix);
    }

    @Override
    public int hashCode() {
        return getPrefix().hashCode() ^ getNamespaceURI().hashCode()
                ^ getLocalPart().hashCode() ^ getAttributeState().hashCode();
    }

    @Override
    public boolean equals(Object objectToTest) {
        if (objectToTest == this) {
            return true;
        }

        if (!(objectToTest instanceof QualifiedName qName)) {
            return false;
        }

        return getPrefix().equals(qName.getPrefix())
                && getLocalPart().equals(qName.getLocalPart())
                && getNamespaceURI().equals(qName.getNamespaceURI())
                && getAttributeState().equals(qName.getAttributeState());
    }
}
