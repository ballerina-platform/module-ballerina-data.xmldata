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
 * A factory for creating a qualified name.
 *
 * @since 0.1.4
 */
public class QualifiedNameFactory {
    public static QualifiedName createQualifiedName(String namespaceURI, String localPart, String prefix,
                                                    QualifiedName.AttributeState attributeState,
                                                    boolean isSemantic) {
        if (isSemantic) {
            return new QualifiedNameSemantic(namespaceURI, localPart, prefix, attributeState);
        }
        return new QualifiedNameSyntax(namespaceURI, localPart, prefix, attributeState);
    }

    public static QualifiedName createQualifiedName(String namespaceURI, String localPart, String prefix,
                                                    boolean isSemantic) {
        if (isSemantic) {
            return new QualifiedNameSemantic(namespaceURI, localPart, prefix);
        }
        return new QualifiedNameSyntax(namespaceURI, localPart, prefix);
    }
}
