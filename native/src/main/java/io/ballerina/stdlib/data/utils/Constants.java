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

import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BString;

/**
 * Constants used in Ballerina XmlData library.
 *
 * @since 0.1.0
 */
public class Constants {

    private Constants() {}

    public static final String UNDERSCORE = "_";
    public static final String COLON = ":";
    public static final MapType JSON_MAP_TYPE = TypeCreator.createMapType(PredefinedTypes.TYPE_JSON);
    public static final ArrayType JSON_ARRAY_TYPE = TypeCreator.createArrayType(PredefinedTypes.TYPE_JSON);
    public static final String FIELD = "$field$.";
    public static final String NAME_SPACE = "Namespace";
    public static final BString URI = StringUtils.fromString("uri");
    public static final BString PREFIX = StringUtils.fromString("prefix");
    public static final String ATTRIBUTE = "Attribute";
    public static final int DEFAULT_TYPE_FLAG = 2049;
    public static final String NAME = "Name";
    public static final BString VALUE = StringUtils.fromString("value");
    public static final String CONTENT = "#content";
}
