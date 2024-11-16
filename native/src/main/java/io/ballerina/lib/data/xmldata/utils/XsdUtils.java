package io.ballerina.lib.data.xmldata.utils;

import io.ballerina.lib.data.xmldata.xml.QualifiedName;
import io.ballerina.lib.data.xmldata.xml.xsd.ChoiceInfo;
import io.ballerina.lib.data.xmldata.xml.xsd.ElementInfo;
import io.ballerina.lib.data.xmldata.xml.xsd.ModelGroupInfo;
import io.ballerina.lib.data.xmldata.xml.xsd.SequenceInfo;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.HashMap;
import java.util.Map;

import static io.ballerina.lib.data.xmldata.utils.DataUtils.XmlAnalyzerMetaData;
import static io.ballerina.lib.data.xmldata.utils.DataUtils.popMappingTypeStacks;

public class XsdUtils {
    public static void initializeXsdInformation(RecordType recordType, XmlAnalyzerMetaData parserData) {
        BMap<BString, Object> annotations = recordType.getAnnotations();
        for (BString annotationKey : annotations.getKeys()) {
            String key = annotationKey.getValue();
            if (key.contains(Constants.FIELD)) {
                String fieldName = key.split(Constants.FIELD_REGEX)[1].replaceAll("\\\\", "");
                Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
                String xmlElementName = DataUtils.getModifiedName(fieldAnnotation, fieldName);
                for (BString fieldAnnotationKey: fieldAnnotation.keySet()) {
                    String fieldAnnotationKeyStr = fieldAnnotationKey.getValue();
                    if (fieldAnnotationKeyStr.startsWith(Constants.MODULE_NAME)) {
                        handleModuleXsdAnnotations(fieldAnnotation, fieldAnnotationKeyStr, fieldName,
                                recordType, fieldAnnotationKey, xmlElementName, parserData);
                    }
                }
            }
        }
    }

    public static void handleModuleXsdAnnotations(Map<BString, Object> fieldAnnotation, String fieldAnnotationKeyStr,
                                            String fieldName, RecordType recordType, BString fieldAnnotationKey,
                                            String xmlElementName, XmlAnalyzerMetaData parserData) {
        if (fieldAnnotationKeyStr.endsWith(Constants.ELEMENT)) {
            handleModuleXsdElementAnnotation(fieldAnnotation, fieldAnnotationKey,
                    fieldName, xmlElementName, parserData);
        } else if (fieldAnnotationKeyStr.endsWith(Constants.SEQUENCE)) {
            handleModuleXsdSequenceAnnotations(fieldAnnotation, fieldName, recordType,
                    fieldAnnotationKey, parserData);
        } else if (fieldAnnotationKeyStr.endsWith(Constants.CHOICE)) {
            handleModuleChoiceSequenceAnnotations(fieldAnnotation, fieldName, recordType,
                    fieldAnnotationKey, parserData);
        }
    }

    public static void handleModuleXsdElementAnnotation(Map<BString, Object> fieldAnnotation,
                BString fieldAnnotationKey, String fieldName, String xmlElementName, XmlAnalyzerMetaData parserData) {
        BMap<BString, Object> fieldAnnotationValue = (BMap<BString, Object>) fieldAnnotation.get(fieldAnnotationKey);
        parserData.xmlElementInfo.peek().put(xmlElementName,
                new ElementInfo(xmlElementName, fieldName, fieldAnnotationValue));
    }

    public static void handleModuleXsdSequenceAnnotations(Map<BString, Object> fieldAnnotation, String fieldName,
                                    RecordType recordType, BString fieldAnnotationKey, XmlAnalyzerMetaData parserData) {
        BMap<BString, Object> fieldAnnotationValue = (BMap<BString, Object>) fieldAnnotation.get(fieldAnnotationKey);
        Type fieldType = TypeUtils.getReferredType(recordType
                .getFields().get(fieldName).getFieldType());
        if (fieldType instanceof RecordType recType) {
            parserData.xsdModelGroupInfo.peek().put(fieldName,
                    new SequenceInfo(fieldName,
                            fieldAnnotationValue, recType, parserData.xmlElementInfo));
        } else if (fieldType instanceof ArrayType arrayType) {
            Type elementType = TypeUtils.getReferredType(arrayType.getElementType());
            if (elementType instanceof RecordType recType) {
                parserData.xsdModelGroupInfo.peek().put(fieldName,
                        new SequenceInfo(fieldName,
                                fieldAnnotationValue, recType, parserData.xmlElementInfo));
            } else {
                throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_SEQUENCE_ANNOTATION, fieldName, fieldType);
            }
        } else {
            throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_SEQUENCE_ANNOTATION, fieldName, fieldType);
        }
    }

    public static void handleModuleChoiceSequenceAnnotations(Map<BString, Object> fieldAnnotation, String fieldName,
                                   RecordType recordType, BString fieldAnnotationKey, XmlAnalyzerMetaData parserData) {
        BMap<BString, Object> fieldAnnotationValue = (BMap<BString, Object>) fieldAnnotation.get(fieldAnnotationKey);
        Type fieldType = TypeUtils.getReferredType(recordType
                .getFields().get(fieldName).getFieldType());
        if (fieldType instanceof RecordType recType) {
            parserData.xsdModelGroupInfo.peek().put(fieldName,
                    new ChoiceInfo(fieldName, fieldAnnotationValue, recType, parserData.xmlElementInfo));
        } else {
            throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_CHOICE_ANNOTATION, fieldName, fieldType);
        }
    }

    public static void validateCurrentElementInfo(XmlAnalyzerMetaData xmlAnalyzerMetaData) {
        if (!xmlAnalyzerMetaData.xmlElementInfo.isEmpty()) {
            xmlAnalyzerMetaData.xmlElementInfo.peek().forEach((key, value) -> value.validate());
        }
    }

    public static void validateElementInfoStack(XmlAnalyzerMetaData xmlAnalyzerMetaData) {
        while (!xmlAnalyzerMetaData.xmlElementInfo.isEmpty()) {
            xmlAnalyzerMetaData.xmlElementInfo.pop().forEach((key, value) -> value.validate());
        }
    }

    public static void validateModelGroupInfoStack(XmlAnalyzerMetaData xmlAnalyzerMetaData) {
        while (!xmlAnalyzerMetaData.xsdModelGroupInfo.isEmpty()) {
            xmlAnalyzerMetaData.xsdModelGroupInfo.pop().forEach((key, value) -> value.validateMinOccurrences());
        }
    }

public static void popXsdValidationStacks(XmlAnalyzerMetaData xmlAnalyzerMetaData) {
        xmlAnalyzerMetaData.xsdModelGroupInfo.pop().forEach((key, value) -> value.validateMinOccurrences());
        xmlAnalyzerMetaData.xmlElementInfo.pop();
    }

    public static void updateElementOccurrence(XmlAnalyzerMetaData xmlAnalyzerMetaData, QualifiedName elemQName) {
        if (!xmlAnalyzerMetaData.xmlElementInfo.isEmpty()) {
            HashMap<String, ElementInfo> elementInfo = xmlAnalyzerMetaData.xmlElementInfo.peek();
            if (elementInfo.containsKey(elemQName.getLocalPart())) {
                elementInfo.get(elemQName.getLocalPart()).updateOccurrences();
            }
        }
    }

    public static void validateModelGroupStack(XmlAnalyzerMetaData xmlAnalyzerMetaData,
                                         QualifiedName elemQName, boolean isStartElement) {
        String localPart = elemQName.getLocalPart();
        while (!xmlAnalyzerMetaData.modelGroupStack.isEmpty()) {
            ModelGroupInfo modelGroup = xmlAnalyzerMetaData.modelGroupStack.peek();
            if ((!modelGroup.isElementContains(localPart)
                    && !modelGroup.isMiddleOfModelGroup())) {
                validateModelGroup(modelGroup, xmlAnalyzerMetaData);
                continue;
            }

            if (isStartElement && modelGroup.predictStartNewModelGroup(localPart)) {
                validateModelGroup(modelGroup, xmlAnalyzerMetaData, false);
                return;
            }

            if (modelGroup.isElementContains(localPart)) {
                modelGroup.visit(localPart, isStartElement);
            }
            return;
        }
    }

    public static void validateModelGroup(ModelGroupInfo modelGroup, XmlAnalyzerMetaData xmlAnalyzerMetaData) {
        validateModelGroup(modelGroup, xmlAnalyzerMetaData, true);
    }

    public static void validateModelGroup(ModelGroupInfo modelGroup,
                                          XmlAnalyzerMetaData xmlAnalyzerMetaData, boolean isTerminated) {
        modelGroup.validate();
        if (isTerminated) {
            modelGroup.validateMinOccurrences();
        }
        xmlAnalyzerMetaData.currentNode = (BMap<BString, Object>) xmlAnalyzerMetaData.nodesStack.pop();
        xmlAnalyzerMetaData.modelGroupStack.pop();
        xmlAnalyzerMetaData.rootRecord = xmlAnalyzerMetaData.recordTypeStack.pop();
        validateCurrentElementInfo(xmlAnalyzerMetaData);
        popElementStacksForValidatingGroup(xmlAnalyzerMetaData);
    }

    public static void popElementStacksForValidatingGroup(XmlAnalyzerMetaData xmlAnalyzerMetaData) {
        popMappingTypeStacks(xmlAnalyzerMetaData);
        xmlAnalyzerMetaData.attributeHierarchy.pop();
        xmlAnalyzerMetaData.arrayIndexes.pop();
        xmlAnalyzerMetaData.xsdModelGroupInfo.pop().forEach((key, value) -> value.validateMinOccurrences());
        xmlAnalyzerMetaData.xmlElementInfo.pop();
    }
}
