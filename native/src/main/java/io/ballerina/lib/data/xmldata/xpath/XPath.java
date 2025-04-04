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
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.types.XmlNodeType;
import io.ballerina.runtime.api.types.semtype.Context;
import io.ballerina.runtime.api.types.semtype.Core;
import io.ballerina.runtime.api.types.semtype.Env;
import io.ballerina.runtime.api.types.semtype.SemType;
import io.ballerina.runtime.api.types.semtype.ShapeAnalyzer;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BObject;
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
import java.util.List;
import java.util.Optional;
import java.util.stream.Stream;

import javax.xml.namespace.QName;
import javax.xml.transform.stream.StreamSource;

import static io.ballerina.runtime.api.utils.StringUtils.fromString;

/**
 * Utility class containing native implementations of functions defined in {@code xpath_api.bal}.
 *
 * @since 1.3.1
 */
public final class XPath {
    private XPath() {

    }
    private static final Processor processor = new Processor(false);

    private static final List<ConvertibleBasicType<?>> DEFAULT_CANDIDATE_TYPES = List.of(
            ConvertibleBasicType.INT,
            ConvertibleBasicType.FLOAT,
            ConvertibleBasicType.DECIMAL,
            ConvertibleBasicType.BOOLEAN,
            ConvertibleBasicType.STRING,
            ConvertibleBasicType.XML
    );

    public static Object transform(BXml value, BObject query, BTypedesc td) {
        try {
            XdmValue result = query(convertRawTemplateToString(query), from(value));
            return convertToBType(result, td);
        } catch (InvalidQueryException | ResultTypeMismatchException e) {
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

    // This is very inefficient, but number of candidates in td is typically small enough that it shouldn't be a
    //  problem
    private static Object convertToSingleValue(Context cx, XdmValue value, BTypedesc td)
            throws ResultTypeMismatchException {
        SemType describingTy = SemType.tryInto(cx, td.getDescribingType());
        return getCandidateSequence(cx, td).filter(candidate -> candidate.isValidCandidate(cx, td))
                .map(candidate -> candidate.tryConvertToType(value))
                .filter(Optional::isPresent)
                .map(Optional::get)
                .filter(v -> {
                    SemType inherentType = ShapeAnalyzer.inherentTypeOf(cx, v)
                            .orElseThrow(() -> new RuntimeException("Inherent type not found for: " + v));
                    return Core.isSubType(cx, inherentType, describingTy);
                })
                .findFirst()
                .orElseThrow(() -> new ResultTypeMismatchException(value, td.getDescribingType()));
    }

    private static Stream<ConvertibleBasicType<?>> getCandidateSequence(Context cx, BTypedesc td) {
        Type describingType = td.getDescribingType();
        if (!(describingType instanceof UnionType unionType)) {
            return DEFAULT_CANDIDATE_TYPES.stream();
        }
        return unionType.getMemberTypes().stream().flatMap(each -> getCandidateConvertibleTypes(cx, each));
    }

    private static Stream<ConvertibleBasicType<?>> getCandidateConvertibleTypes(Context cx, Type type) {
        SemType ty = SemType.tryInto(cx, type);
        return DEFAULT_CANDIDATE_TYPES.stream().filter(each -> Core.containsBasicType(ty, each.basicType()));
    }

    private static Object convertToNil(Context cx, XdmValue value, BTypedesc td) throws ResultTypeMismatchException {
        ConvertibleBasicType<Object> nil = ConvertibleBasicType.NIL;
        if (nil.isValidCandidate(cx, td)) {
            return null;
        }
        throw new ResultTypeMismatchException(value, td.getDescribingType());
    }

    private static XdmValue query(String xPath, String xml) throws InvalidQueryException {
        DocumentBuilder builder = processor.newDocumentBuilder();
        XdmNode xmlDocument;
        try {
            xmlDocument = builder.build(new StreamSource((new StringReader(xml))));
        } catch (SaxonApiException e) {
            // This should never happen since we are starting with a valid xml value
            throw new RuntimeException(e);
        }

        XPathCompiler xpathCompiler = processor.newXPathCompiler();
        try {
            XPathExecutable executable = xpathCompiler.compile(xPath);
            XPathSelector selector = executable.load();

            selector.setContextItem(xmlDocument);
            return selector.evaluate();
        } catch (SaxonApiException e) {
            throw new InvalidQueryException(xPath);
        }
    }

    private static String from(BXml bXml) {
        BXml xmlInput = bXml;
        // Copied this workaround from XSLT library, ideally we should be able to do something better.
        if (xmlInput.getNodeType() == XmlNodeType.SEQUENCE) {
            xmlInput = ValueCreator.createXmlItem(new QName("root"), (BXmlSequence) xmlInput);
            String input = xmlInput.toString();
            // Remove <root></root> wrapper
            return input.substring(6, input.length() - 7).trim();
        }
        return xmlInput.toString();
    }

    public static String convertRawTemplateToString(BObject rawTemplate) {
        BArray insertionsArray = rawTemplate.getArrayValue(fromString("insertions"));
        BArray stringsArray = rawTemplate.getArrayValue(fromString("strings"));
        int stringArraySize = stringsArray.size();
        if (stringArraySize == 0) {
            return "";
        } else {
            long insertionLength = insertionsArray.getLength();
            StringBuilder query = new StringBuilder(stringsArray.getBString(0).getValue());
            for (int i = 1; i < stringArraySize; i++) {
                String templatedString = "";
                if (i - 1 < insertionLength) {
                    templatedString = StringUtils.getStringValue(insertionsArray.get(i - 1));
                }
                query.append(templatedString).append(stringsArray.getBString(i).getValue());
            }
            return query.toString();
        }
    }
}
