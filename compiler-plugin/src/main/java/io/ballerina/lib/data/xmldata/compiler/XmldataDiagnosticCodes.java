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

package io.ballerina.lib.data.xmldata.compiler;

import io.ballerina.tools.diagnostics.DiagnosticSeverity;

import static io.ballerina.tools.diagnostics.DiagnosticSeverity.ERROR;
import static io.ballerina.tools.diagnostics.DiagnosticSeverity.WARNING;

/**
 * Enum class to hold xmldata module diagnostic codes.
 *
 * @since 0.1.0
 */
public enum XmldataDiagnosticCodes {

    DUPLICATE_FIELD("XML_ERROR_201", "invalid field: duplicate field found", ERROR),
    UNSUPPORTED_UNION_TYPE("XML_ERROR_202",
            "unsupported union type: union type does not support multiple non-primitive record types", ERROR),
    UNSUPPORTED_TYPE("XML_ERROR_203", "unsupported type: the record field does not support the expected type", ERROR),
    EXPECTED_RECORD_TYPE("XML_ERROR_204", "invalid type: expected a record type", ERROR),
    NAME_ANNOTATION_NOT_ALLOWED("XML_ERROR_205",
            "invalid annotation attachment: child record does not allow name annotation", WARNING),
    INVALID_XSD_MODEL_GROUP_ANNOTATION("XML_ERROR_206",
            "invalid xsd annotation: record type or record array type expected", ERROR),
    INVALID_SEQUENCE_TYPE("XML_ERROR_207",
            "Invalid sequence member: Order should be defined in in all fields", ERROR),
    INVALID_SEQUENCE_REST_TYPE("XML_ERROR_208",
            "Invalid sequence member: Sequence members should be defined in a closed record", ERROR),
    INVALID_CHOICE_REST_TYPE("XML_ERROR_209",
            "Invalid choice member: Choice members should be defined in a closed record", ERROR),
    INVALID_ANNOTATIONS("XML_ERROR_210", "A record field cannot contains " +
            "sequence/choice/element/attribute annotations simultaneously", ERROR),
    UNSUPPORTED_XPATH_TYPE("XML_ERROR_211", "unsupported type: XPath projection does not support the " +
            "expected type", ERROR);

    private final String code;
    private final String message;
    private final DiagnosticSeverity severity;

    XmldataDiagnosticCodes(String code, String message, DiagnosticSeverity severity) {
        this.code = code;
        this.message = message;
        this.severity = severity;
    }

    public String getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }

    public DiagnosticSeverity getSeverity() {
        return severity;
    }
}
