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

package io.ballerina.stdlib.data.xmldata.compiler.objects;

public class QualifiedName {
    private final String localPart;
    private final String namespaceURI;
    private final String prefix;

    public QualifiedName(String namespaceURI, String localPart, String prefix) {
        this.localPart = localPart;
        this.namespaceURI = namespaceURI;
        this.prefix = prefix;
    }

    @Override
    public int hashCode() {
        return localPart.hashCode() ^ namespaceURI.hashCode() ^ prefix.hashCode();
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
        return localPart.equals(qName.localPart) && namespaceURI.equals(qName.namespaceURI) &&
                prefix.equals(qName.prefix);
    }
}
