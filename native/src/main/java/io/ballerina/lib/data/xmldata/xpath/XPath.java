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

import io.ballerina.lib.data.xmldata.utils.DiagnosticLog;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.XmlNodeType;
import io.ballerina.runtime.api.types.semtype.Context;
import io.ballerina.runtime.api.types.semtype.Core;
import io.ballerina.runtime.api.types.semtype.Env;
import io.ballerina.runtime.api.types.semtype.SemType;
import io.ballerina.runtime.api.types.semtype.ShapeAnalyzer;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.runtime.api.values.BXml;
import io.ballerina.runtime.api.values.BXmlSequence;
import net.sf.saxon.s9api.DocumentBuilder;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XPathCompiler;
import net.sf.saxon.s9api.XPathExecutable;
import net.sf.saxon.s9api.XPathSelector;
import net.sf.saxon.s9api.XdmItem;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XdmSequenceIterator;
import net.sf.saxon.s9api.XdmValue;
import org.ballerinalang.langlib.xml.Concat;

import java.io.StringReader;
import java.util.Optional;

import javax.xml.namespace.QName;
import javax.xml.transform.stream.StreamSource;

public class XPath {
    private static final Processor processor = new Processor(false);
    private static final ConvertibleBasicType<?>[] SIMPLE_BASIC_TYPES = {
        ConvertibleBasicType.INT,
        ConvertibleBasicType.FLOAT,
        ConvertibleBasicType.DECIMAL,
        ConvertibleBasicType.BOOLEAN,
        ConvertibleBasicType.STRING,
    };

    public static Object transform(BString query, BXml value, BTypedesc td) {
        try {
            XdmValue result = query(from(query), from(value));
            return convertToBType(result, td);
        } catch (SaxonApiException | ResultTypeMismatchException | NumberFormatException e) {
            // TODO: handle SaxonApiException properly without exposing it to the user
            return DiagnosticLog.createXmlError(e.getMessage());
        }
    }

    private static Object convertToBType(XdmValue value, BTypedesc td) throws ResultTypeMismatchException {
        Context cx = Context.from(Env.getInstance());
        assert !Core.isNever(SemType.tryInto(cx, td.getDescribingType())) :
                "Target type must not be never";
        return switch (value.size()) {
            case 0 -> convertToNil(cx, value, td);
            case 1 -> convertToSingleValue(cx, value, td);
            default -> convertToSequence(cx, value, td);
        };
    }

    private static Object convertToSequence(Context cx, XdmValue value, BTypedesc td)
            throws ResultTypeMismatchException {
        if (!ConvertibleBasicType.XML.isValidCandidate(cx, td)) {
            throw new ResultTypeMismatchException(value, td.getDescribingType());
        }
        XdmSequenceIterator<XdmItem> it = value.iterator();
        // This is guaranteed to work since we have an XML to begin with
        Object[] items = it.stream().map(ConvertibleBasicType.XML::convertToType).toArray(BXml[]::new);
        return Concat.concat(items);
    }

    private static Object convertToSingleValue(Context cx, XdmValue value, BTypedesc td)
            throws ResultTypeMismatchException {
        Type describingType = td.getDescribingType();
        SemType ty = SemType.tryInto(cx, describingType);
        if (Core.containsBasicType(ty, ConvertibleBasicType.XML.basicType())) {
            // This is guaranteed to work since we have an XML to begin with
            return ConvertibleBasicType.XML.convertToType(value);
        }
        String xmlString = value.iterator().next().getStringValue();
        for (var each: SIMPLE_BASIC_TYPES) {
            Optional<?> result = tryConvertToSimpleBasicType(cx, xmlString, each, ty);
            if (result.isPresent()) {
                return result.get();
            }
        }
        throw new ResultTypeMismatchException(value, describingType);
    }

    private static <E> Optional<E> tryConvertToSimpleBasicType(Context cx, String xml,
            ConvertibleBasicType<E> convertibleType, SemType targetType) {
        SemType basicType = convertibleType.basicType();
        if (!Core.containsBasicType(targetType, basicType)) {
            return Optional.empty();
        }
        Optional<E> result = convertibleType.tryConvertToType(xml);
        if (targetType.some() == 0 || result.isEmpty()) {
            return result;
        }
        E value = result.get();
        // Note we have converted to the basic type now we need to check if it is a subtype of the target type.
        SemType inherentType = ShapeAnalyzer.inherentTypeOf(cx, value)
                .orElseGet(() -> SemType.tryInto(cx, TypeUtils.getType(value)));
        if (!Core.isSubType(cx, inherentType, targetType)) {
            return Optional.empty();
        }
        return result;
    }

    private static Object convertToNil(Context cx, XdmValue value, BTypedesc td) throws ResultTypeMismatchException {
        ConvertibleBasicType<Object> nil = ConvertibleBasicType.NIL;
        if (nil.isValidCandidate(cx, td)) {
            return null;
        }
        throw new ResultTypeMismatchException(value, td.getDescribingType());
    }

    static XdmValue query(String xPath, String xml) throws SaxonApiException {
        DocumentBuilder builder = processor.newDocumentBuilder();
        XdmNode xmlDocument = builder.build(new StreamSource((new StringReader(xml))));

        XPathCompiler xpathCompiler = processor.newXPathCompiler();
        XPathExecutable executable = xpathCompiler.compile(xPath);
        XPathSelector selector = executable.load();

        selector.setContextItem(xmlDocument);
        return selector.evaluate();
    }

    private static String from(BString bString) {
        return bString.getValue();
    }

    private static String from(BXml bXml) {
        BXml xmlInput = bXml;
        if (xmlInput.getNodeType() == XmlNodeType.SEQUENCE) {
            xmlInput = ValueCreator.createXmlItem(new QName("root"), (BXmlSequence) xmlInput);
            String input = xmlInput.toString();
            // Remove <root></root> wrapper
            return input.substring(6, input.length() - 7).trim();
        }
        return xmlInput.toString();
    }
}
