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

import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.types.PredefinedTypes;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BXmlItem;

/**
 * Constants used in Ballerina XmlData library.
 *
 * @since 0.1.0
 */
public class Constants {

    private Constants() {}

    public static final int NS_PREFIX_BEGIN_INDEX = BXmlItem.XMLNS_NS_URI_PREFIX.length();
    public static final int DEFAULT_TYPE_FLAG = 2049;

    public static final String FIELD = "$field$.";
    public static final String ROOT_TAG = "rootTag";
    public static final String ROOT = "root";
    public static final String EMPTY_STRING = "";
    public static final String NAMESPACE = "Namespace";
    public static final String UNDERSCORE = "_";
    public static final String COLON = ":";
    public static final String ATTRIBUTE = "Attribute";
    public static final String NAME = "Name";
    public static final String CONTENT = "#content";
    public static final String FIELD_REGEX = "\\$field\\$\\.";
    public static final String RECORD = "record";
    public static final String RECORD_OR_MAP = "record or map";
    public static final String ANON_TYPE = "$anonType$";
    public static final String RECORD_FIELD_NAME_ESCAPE_CHAR_REGEX = "[^a-zA-Z\\d\s_]";
    public static final String NS_ANNOT_NOT_DEFINED = "$$ns_annot_not_defined$$";
    public static final String MODULE_NAME = "ballerina/data.xmldata";
    public static final String REGEXP_MODULE_NAME = "lang.regexp";
    public static final String REGEXP_TYPE_NAME = "RegExp";

    public static final BString URI = StringUtils.fromString("uri");
    public static final BString PREFIX = StringUtils.fromString("prefix");
    public static final BString VALUE = StringUtils.fromString("value");
    public static final BString ATTRIBUTE_PREFIX = StringUtils.fromString("attributePrefix");
    public static final BString USER_ATTRIBUTE_PREFIX = StringUtils.fromString("userAttributePrefix");
    public static final BString TEXT_FIELD_NAME = StringUtils.fromString("textFieldName");
    public static final BString ARRAY_ENTRY_TAG = StringUtils.fromString("arrayEntryTag");
    public static final BString ALLOW_DATA_PROJECTION = StringUtils.fromString("allowDataProjection");
    public static final BString USE_SEMANTIC_EQUALITY = StringUtils.fromString("useSemanticEquality");
    public static final BString ENABLE_CONSTRAINT_VALIDATION = StringUtils.fromString("enableConstraintValidation");

    public static final MapType JSON_MAP_TYPE = TypeCreator.createMapType(PredefinedTypes.TYPE_JSON);
    public static final ArrayType JSON_ARRAY_TYPE = TypeCreator.createArrayType(PredefinedTypes.TYPE_JSON);

    public static final String ELEMENT = "Element";
    public static final String SEQUENCE = "Sequence";
    public static final String CHOICE = "Choice";
    public static final BString MIN_OCCURS = StringUtils.fromString("minOccurs");
    public static final BString MAX_OCCURS = StringUtils.fromString("maxOccurs");
    public static final String ORDER = "SequenceOrder";
}
