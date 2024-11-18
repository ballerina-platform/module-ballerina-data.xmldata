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

import io.ballerina.lib.data.xmldata.utils.Constants;
import io.ballerina.lib.data.xmldata.utils.DiagnosticErrorCode;
import io.ballerina.lib.data.xmldata.utils.DiagnosticLog;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

/**
 * Represent xsd element.
 *
 * @since 1.1.0
 */
public class ElementInfo {
    String name;
    String fieldName;
    public long minOccurs;
    public long maxOccurs;
    public int occurrences;

    public boolean isInsideChoice = false;

    public ElementInfo(String name, String fieldName, BMap<BString, Object> element) {
        this.name = name;
        this.fieldName = fieldName;
        if (element.containsKey(Constants.MIN_OCCURS)) {
            this.minOccurs = element.getIntValue(Constants.MIN_OCCURS);
        } else {
            this.minOccurs = 1;
        }

        if (element.containsKey(Constants.MAX_OCCURS)) {
            this.maxOccurs = element.getIntValue(Constants.MAX_OCCURS);
        } else {
            this.maxOccurs = Math.max(this.minOccurs, 1);
        }
        this.occurrences = 0;
    }

    public void updateOccurrences() {
        this.occurrences++;
        if (this.occurrences > this.maxOccurs) {
            throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_MORE_THAN_MAX_ALLOWED_TIMES, name);
        }
    }

    public void validate() {
        validateMinOccurrences();
    }

    private void validateMinOccurrences() {
        if (!isInsideChoice && this.occurrences < this.minOccurs) {
            throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_LESS_THAN_MIN_REQUIRED_TIMES, name);
        }
    }
}
