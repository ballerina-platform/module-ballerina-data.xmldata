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

package io.ballerina.stdlib.data.xmldata.compiler;

import io.ballerina.tools.diagnostics.DiagnosticSeverity;

import static io.ballerina.tools.diagnostics.DiagnosticSeverity.ERROR;
import static io.ballerina.tools.diagnostics.DiagnosticSeverity.WARNING;

/**
 * Enum class to hold xmldata module diagnostic codes.
 *
 * @since 0.1.0
 */
public enum XmldataDiagnosticCodes {

    DUPLICATE_FIELD("BDE201", "invalid field: duplicate field found", ERROR),
    UNSUPPORTED_UNION_TYPE("BDE202",
            "unsupported union type: union type does not support multiple non-primitive record types", ERROR),
    UNSUPPORTED_TYPE("BDE203", "unsupported type: the record field does not support the expected type", ERROR),
    EXPECTED_RECORD_TYPE("BDE204", "invalid type: expected a record type", ERROR),
    NAME_ANNOTATION_NOT_ALLOWED("BDE204",
            "invalid annotation attachment: child record does not allow name annotation", WARNING);

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
