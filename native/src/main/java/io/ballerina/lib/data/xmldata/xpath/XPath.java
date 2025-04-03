package io.ballerina.lib.data.xmldata.xpath;

import io.ballerina.lib.data.xmldata.utils.DiagnosticLog;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.XmlNodeType;
import io.ballerina.runtime.api.types.semtype.BasicTypeBitSet;
import io.ballerina.runtime.api.types.semtype.Builder;
import io.ballerina.runtime.api.types.semtype.Context;
import io.ballerina.runtime.api.types.semtype.Core;
import io.ballerina.runtime.api.types.semtype.Env;
import io.ballerina.runtime.api.types.semtype.SemType;
import io.ballerina.runtime.api.types.semtype.ShapeAnalyzer;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.utils.XmlUtils;
import io.ballerina.runtime.api.values.BDecimal;
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
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XdmValue;

import java.io.StringReader;
import java.util.Optional;
import java.util.function.Function;

import javax.xml.namespace.QName;
import javax.xml.transform.stream.StreamSource;

public class XPath {

    private static final Processor processor = new Processor(false);

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
        assert !Core.isNever(SemType.tryInto(Context.from(Env.getInstance()), td.getDescribingType())) :
                "Target type must not be never";
        return switch (value.size()) {
            case 0 -> convertToNil(value, td);
            case 1 -> convertToSingleValue(value, td);
            default -> convertToSequence(value, td);
        };
    }

    private static Object convertToSequence(XdmValue value, BTypedesc td) throws ResultTypeMismatchException {
        Context cx = Context.from(Env.getInstance());
        SemType ty = SemType.tryInto(cx, td.getDescribingType());
        if (!isSequenceType(cx, ty)) {
            throw new ResultTypeMismatchException(value, td.getDescribingType());
        }
        throw new RuntimeException("sequence type not implemented yet");
    }

    private static Object convertToSingleValue(XdmValue value, BTypedesc td) throws ResultTypeMismatchException {
        Context cx = Context.from(Env.getInstance());
        Type describingType = td.getDescribingType();
        SemType ty = SemType.tryInto(cx, describingType);
        if (Core.containsBasicType(ty, Builder.getXmlType())) {
            return createXmlItemFrom(value);
        }
        String repr = value.iterator().next().getStringValue();
        Optional<Object> bValue =  tryConvertToBasicType(widenType(ty), repr);
        if (bValue.isPresent()) {
            Object inner =  bValue.get();
            if (belongToType(cx, inner, ty)) {
                return inner;
            }
        }
        throw new ResultTypeMismatchException(value, describingType);
    }

    private static BXml createXmlItemFrom(XdmValue value) {
        return XmlUtils.parse(value.toString().trim());
    }

    private static boolean belongToType(Context cx, Object object, SemType targetType) {
        SemType valueTy = ShapeAnalyzer.inherentTypeOf(cx, object)
                .orElseGet(() -> SemType.tryInto(cx, TypeUtils.getType(object)));
        return Core.isSubType(cx, valueTy, targetType);
    }

    private static BasicTypeBitSet widenType(SemType ty) {
        return SemType.from(ty.all() | ty.some());
    }

    // TODO: clean this up
    private static Optional<Object> tryConvertToBasicType(BasicTypeBitSet ty, String repr) {
        if (Core.containsBasicType(ty, Builder.getIntType())) {
            Optional<Long> result = tryConvert(repr, Long::valueOf);
            if (result.isPresent()) {
                return Optional.of(result.get());
            }
        }
        if (Core.containsBasicType(ty, Builder.getFloatType())) {
            Optional<Double> result = tryConvert(repr, Double::valueOf);
            if (result.isPresent()) {
                return Optional.of(result.get());
            }
        }
        if (Core.containsBasicType(ty, Builder.getDecimalType())) {
            Optional<BDecimal> result = tryConvert(repr, ValueCreator::createDecimalValue);
            if (result.isPresent()) {
                return Optional.of(result.get());
            }
        }
        if (Core.containsBasicType(ty, Builder.getBooleanType())) {
            Optional<Boolean> result = tryConvert(repr, XPath::booleanValueOf);
            if (result.isPresent()) {
                return Optional.of(result.get());
            }
        }
        if (Core.containsBasicType(ty, Builder.getStringType())) {
            Optional<BString> result = tryConvert(repr, StringUtils::fromString);
            if (result.isPresent()) {
                return Optional.of(result.get());
            }
        }
        return Optional.empty();
    }

    private static Boolean booleanValueOf(String repr) {
        if (repr.equalsIgnoreCase("true")) {
            return true;
        } else if (repr.equalsIgnoreCase("false")) {
            return false;
        }
        throw new IllegalArgumentException("Invalid boolean value: " + repr);
    }

    private static <T> Optional<T> tryConvert(String repr, Function<String, T> convertFn) {
        try {
            return Optional.ofNullable(convertFn.apply(repr));
        } catch (Exception e) {
            return Optional.empty();
        }
    }

    private static Object convertToNil(XdmValue value, BTypedesc td) throws ResultTypeMismatchException {
        Context cx = Context.from(Env.getInstance());
        SemType ty = SemType.tryInto(cx, td.getDescribingType());
        if (Core.isSubtypeSimple(Builder.getNilType(), ty)) {
            return null;
        }
        throw new ResultTypeMismatchException(value, td.getDescribingType());
    }

    private static boolean isSequenceType(Context cx, SemType ty) {
        SemType sequenceType = Builder.getListType();
        // TODO: properly build this
        return Core.isSubType(cx, ty, sequenceType);
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
