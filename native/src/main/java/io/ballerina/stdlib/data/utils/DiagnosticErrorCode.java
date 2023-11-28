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
package io.ballerina.stdlib.data.utils;

/**
 * Represents a diagnostic error code.
 *
 * @since 0.0.1
 */
public enum DiagnosticErrorCode {

    UNSUPPORTED_TYPE("BDE_0001", "unsupported.type"),
    XML_ROOT_MISSING("BDE_0002", "xml.root.missing"),
    INVALID_REST_TYPE("BDE_0003", "invalid.rest.type"),
    ARRAY_SIZE_MISMATCH("BDE_0004", "array.size.mismatch"),
    REQUIRED_FIELD_NOT_PRESENT("BDE_0005", "required.field.not.present"),
    REQUIRED_ATTRIBUTE_NOT_PRESENT("BDE_0006", "required.attribute.not.present"),
    DUPLICATE_FIELD("BDE_0007", "duplicate.field"),
    FOUND_ARRAY_FOR_NON_ARRAY_TYPE("BDE_0008", "found.array.for.non.array.type"),
    EXPECTED_ANYDATA_OR_JSON("BDE_0009", "expected.anydata.or.json"),
    NAMESPACE_MISMATCH("BDE_0010", "namespace.mismatch"),
    TYPE_NAME_MISMATCH_WITH_XML_ELEMENT("BDE_0011", "type.name.mismatch.with.xml.element");

    String diagnosticId;
    String messageKey;

    DiagnosticErrorCode(String diagnosticId, String messageKey) {
        this.diagnosticId = diagnosticId;
        this.messageKey = messageKey;
    }

    public String messageKey() {
        return messageKey;
    }
}
