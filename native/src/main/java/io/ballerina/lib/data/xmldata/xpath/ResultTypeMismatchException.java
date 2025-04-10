/*
 *  Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com).
 *
 *  WSO2 LLC. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

package io.ballerina.lib.data.xmldata.xpath;

import io.ballerina.runtime.api.types.Type;

/**
 * Exception thrown when there is a mismatch between the expected and actual result type in result of XPath operations.
 *
 * @since 1.3.1
 */
class ResultTypeMismatchException extends Exception {

    ResultTypeMismatchException(Object value, Type targetType) {
        super(errorMessage(value, targetType));
    }

    private static String errorMessage(Object value, Type targetType) {
        return "Value: " + value + " cannot be converted to type: " + targetType;
    }
}
