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

import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;

/**
 * A util class for the Data package's native implementation.
 *
 * @since 0.1.0
 */
public class DataUtils {

    private static final String ERROR = "ConversionError";
    private static final String NAME = "Name";
    private static final String ATTRIBUTE_PREFIX = "attribute_";
    private static final String VALUE = "value";

    public static BError getError(String message) {
        return ErrorCreator.createError(ModuleUtils.getModule(), ERROR, StringUtils.fromString(message),
                null, null);
    }

    public static BError getXmlError(String message) {
        return ErrorCreator.createError(ModuleUtils.getModule(), ERROR, StringUtils.fromString(message),
                null, null);
    }
}
