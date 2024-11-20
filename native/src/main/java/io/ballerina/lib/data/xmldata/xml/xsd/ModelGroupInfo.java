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

package io.ballerina.lib.data.xmldata.xml.xsd;

/**
 * Represent the xsd model group.
 *
 * @since 1.1.0
 */
public interface ModelGroupInfo {
    void validate();
    void visit(String element, boolean isStartElement);
    boolean isElementContains(String elementName);
    boolean isMiddleOfModelGroup();
    boolean predictStartNewModelGroup(String element);
    void validateMinOccurrences();
    long getMinOccurs();
    long getMaxOccurs();
    String getFieldName();
}
