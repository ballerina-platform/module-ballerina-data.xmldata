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

package io.ballerina.lib.data.xmldata.utils;

/**
 * Represents a qualified name.
 *
 * @since 0.1.0
 */
public abstract class QualifiedName {
    private String localPart;
    private String namespaceURI;
    private String prefix;
    private AttributeState attributeState = AttributeState.NOT_DEFINED;

    public enum AttributeState {
        ATTRIBUTE,
        ELEMENT,
        NOT_DEFINED
    }

    public QualifiedName(String namespaceURI, String localPart, String prefix, AttributeState attributeState) {
        this.localPart = localPart;
        this.namespaceURI = namespaceURI;
        this.prefix = prefix;
        this.attributeState = attributeState;
    }

    public QualifiedName(String namespaceURI, String localPart, String prefix) {
        this.localPart = localPart;
        this.namespaceURI = namespaceURI;
        this.prefix = prefix;
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

    public void setAttributeState(AttributeState attributeState) {
        this.attributeState = attributeState;
    }

    public AttributeState getAttributeState() {
        return this.attributeState;
    }
}
