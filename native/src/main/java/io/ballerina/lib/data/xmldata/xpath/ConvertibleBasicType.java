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

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.semtype.Builder;
import io.ballerina.runtime.api.types.semtype.Context;
import io.ballerina.runtime.api.types.semtype.Core;
import io.ballerina.runtime.api.types.semtype.SemType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.XmlUtils;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.runtime.api.values.BXml;
import net.sf.saxon.s9api.XdmValue;

import java.util.Optional;
import java.util.function.Function;

interface ConvertibleBasicType<E> {

    SemType basicType();
    E convertToType(String xmlString);

    default E convertToType(XdmValue xml) {
        assert xml.size() == 1;
        return convertToType(xml.iterator().next().getStringValue());
    }
    default Optional<E> tryConvertToType(String xmlString) {
        try {
            return Optional.of(convertToType(xmlString));
        } catch (Exception ignored) {
            return Optional.empty();
        }
    }

    default boolean isValidCandidate(Context cx, BTypedesc targetTd) {
        SemType ty = SemType.tryInto(cx, targetTd.getDescribingType());
        return Core.containsBasicType(ty, basicType());
    }

    ConvertibleBasicType<Long> INT = new BasicTypeHolder<>(Builder.getIntType(), Long::valueOf, "INT");
    ConvertibleBasicType<Double> FLOAT = new BasicTypeHolder<>(Builder.getFloatType(), Double::valueOf, "FLOAT");
    ConvertibleBasicType<BDecimal> DECIMAL = new BasicTypeHolder<>(
            Builder.getDecimalType(), ValueCreator::createDecimalValue, "DECIMAL");
    ConvertibleBasicType<BString> STRING = new BasicTypeHolder<>(
            Builder.getStringType(), StringUtils::fromString, "STRING");

    ConvertibleBasicType<Boolean> BOOLEAN = new BasicTypeHolder<>(
            Builder.getBooleanType(), (repr) -> {
        if (repr.equalsIgnoreCase("true")) {
            return true;
        } else if (repr.equalsIgnoreCase("false")) {
            return false;
        }
        throw new IllegalArgumentException("Invalid boolean value: " + repr);
    }, "BOOLEAN");

    ConvertibleBasicType<Object> NIL = new BasicTypeHolder<>(Builder.getNilType(), (repr) -> {
        assert repr.isEmpty();
        return null;
    }, "NIL");

    ConvertibleBasicType<BXml> XML = new ConvertibleBasicType<>() {
        @Override
        public SemType basicType() {
            return Builder.getXmlType();
        }

        @Override
        public BXml convertToType(String xmlString) {
            return XmlUtils.parse(xmlString);
        }

        @Override
        public BXml convertToType(XdmValue xml) {
            return convertToType(xml.toString().trim());
        }

        @Override
        public String toString() {
            return "ConvertibleBasicType[XML]";
        }
    };

    record BasicTypeHolder<E>(SemType basicType, Function<String, E> convertFn, String name)
            implements ConvertibleBasicType<E> {

        @Override
        public String toString() {
            // This is help with debugging
            return "ConvertibleBasicType[" + name + "]";
        }

        @Override
        public E convertToType(String xmlString) {
            return convertFn.apply(xmlString);
        }
    }
}
