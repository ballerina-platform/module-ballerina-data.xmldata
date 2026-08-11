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

package io.ballerina.lib.data.xmldata.utils;

import io.ballerina.lib.data.xmldata.utils.xsd.ChoiceInfo;
import io.ballerina.lib.data.xmldata.utils.xsd.ElementInfo;
import io.ballerina.lib.data.xmldata.utils.xsd.ModelGroupInfo;
import io.ballerina.lib.data.xmldata.utils.xsd.SequenceInfo;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.utils.ValueUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.runtime.api.values.BXml;
import org.ballerinalang.langlib.map.ToArray;
import org.ballerinalang.langlib.xml.Concat;
import org.ballerinalang.langlib.xml.CreateElement;
import org.ballerinalang.langlib.xml.CreateText;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.IdentityHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * A util class for the record to xml implementation.
 *
 * @since 1.1.0
 */
public class ToXmlUtils {
    private static final BString XMLNS_NAMESPACE_URI = StringUtils.fromString("http://www.w3.org/2000/xmlns/");
    private static final BString ATTRIBUTE_PREFIX = StringUtils.fromString("attribute_");
    private static final BString XMLNS = StringUtils.fromString("xmlns");

    /**
     * Annotation-derived metadata of a record type, computed once per type per conversion.
     * All contained structures are read-only after construction; they are derived purely
     * from the type's annotations, so they can be safely shared across all values of the
     * same type within a single conversion.
     */
    private static final class TypeMetadata {
        final HashMap<DataUtils.FieldAnnotationValue, String> elementNamesMap;
        final HashMap<String, ModelGroupInfo> modelGroupRelatedFieldNames;
        final HashMap<String, ElementInfo> elementInfoRelatedFieldNames;
        final ArrayList<String> sequenceFieldNames;
        final HashMap<String, Integer> xsdSequencePriorityOrderWhenInSequence;

        TypeMetadata(Type referredType) {
            this.elementNamesMap = DataUtils.getElementNameMap(referredType);
            this.modelGroupRelatedFieldNames = getModelGroupRelatedFieldNames(referredType, elementNamesMap);
            this.elementInfoRelatedFieldNames = getElementInfoRelatedFieldNames(referredType);
            this.sequenceFieldNames = getSequenceFieldNames(referredType);
            this.xsdSequencePriorityOrderWhenInSequence = DataUtils.getXsdSequencePriorityOrder(referredType, true);
        }
    }

    /**
     * Returns the annotation-derived metadata for a type, computing it on first use and
     * reusing it for every subsequent value of the same type within one conversion.
     *
     * @param cache        the per-conversion metadata cache, keyed by type identity
     * @param referredType the referred (dereferenced) type to look up
     * @return the cached or freshly computed metadata for the type
     */
    private static TypeMetadata getTypeMetadata(IdentityHashMap<Type, TypeMetadata> cache, Type referredType) {
        TypeMetadata metadata = cache.get(referredType);
        if (metadata == null) {
            metadata = new TypeMetadata(referredType);
            cache.put(referredType, metadata);
        }
        return metadata;
    }

    /**
     * Converts a record or map value to an {@code xml} value. This is the native
     * implementation behind {@code xmldata:toXml}.
     *
     * @param jsonValue the value to convert, already pre-processed by {@code getModifiedRecord}
     * @param options   the JSON-to-XML conversion options
     * @param typed     the typedesc of the original input, used to read annotations
     * @return the converted {@code BXml} value, or a {@code BError} on failure
     */
    public static Object fromRecordToXml(Object jsonValue, BMap<BString, Object> options, BTypedesc typed) {
        try {
            Type type = typed.getDescribingType();
            Type referredType = TypeUtils.getReferredType(type);
            Object rootTag = options.get(StringUtils.fromString(Constants.ROOT_TAG));
            BMap<BString, BString> allNamespaces = getEmptyStringMap();
            IdentityHashMap<Type, TypeMetadata> typeMetadataCache = new IdentityHashMap<>();
            BString rootTagBstring =
                    StringUtils.fromString(rootTag == null ? Constants.EMPTY_STRING : rootTag.toString());

            if (!isSingleRecordMember(jsonValue)) {
                addNamespaces(allNamespaces, getNamespacesMap(jsonValue, options, getEmptyStringMap()));
                return getElementFromRecordMember(
                        rootTag == null ? StringUtils.fromString(Constants.ROOT) : rootTagBstring,
                        traverseRecordAndGenerateXml(jsonValue, allNamespaces,
                                getEmptyStringMap(), options, null, type,
                                false, false, null, null, typeMetadataCache),
                        allNamespaces, options,
                        getAttributesMap(jsonValue, options, allNamespaces, getEmptyStringMap()));
            }

            BMap<BString, Object> jMap = null;
            try {
                jMap = (BMap<BString, Object>) ValueUtils
                        .convert(jsonValue, Constants.JSON_MAP_TYPE);
            } catch (BError e) {
                return jsonValue == null ? ValueCreator.createXmlValue(Constants.EMPTY_STRING)
                        : CreateText.createText(StringUtils.fromString(jsonValue.toString()));
            }

            if (jMap.isEmpty()) {
                return ValueCreator.createXmlValue(Constants.EMPTY_STRING);
            }

            BString key = jMap.getKeys()[0];
            String jsonKey = key.getValue();
            TypeMetadata typeMetadata = getTypeMetadata(typeMetadataCache, referredType);
            HashMap<DataUtils.FieldAnnotationValue, String> elementNamesMap = typeMetadata.elementNamesMap;
            ArrayList<String> sequenceFieldNames = typeMetadata.sequenceFieldNames;
            HashMap<String, ModelGroupInfo> modelGroupRelatedFieldNames = typeMetadata.modelGroupRelatedFieldNames;
            HashMap<String, ElementInfo> elementInfoRelatedFieldNames = typeMetadata.elementInfoRelatedFieldNames;

            boolean isKeyContainsPrefix = jsonKey.contains(Constants.COLON);
            Object value = ToArray.toArray(jMap).getValues()[0];
            addNamespaces(allNamespaces, getNamespacesMap(value, options, getEmptyStringMap()));
            String localJsonKeyPart = getElementLocalKeyPart(isKeyContainsPrefix, jsonKey);
            DataUtils.FieldAnnotationValue jsonKeyFieldAnnotation = getElementNamesMapKey(
                    isKeyContainsPrefix, jsonKey, allNamespaces, localJsonKeyPart);

            String recordKey = elementNamesMap.getOrDefault(jsonKeyFieldAnnotation, localJsonKeyPart);
            boolean isSequenceField = sequenceFieldNames.contains(recordKey);
            boolean isContainsModelGroup = modelGroupRelatedFieldNames.containsKey(recordKey);
            ModelGroupInfo parentModelGroupInfo = modelGroupRelatedFieldNames.get(recordKey);
            ElementInfo elementInfo = elementInfoRelatedFieldNames.get(recordKey);

            if (value instanceof BArray) {
                return getElementFromRecordMember(rootTag == null
                                ? StringUtils.fromString(Constants.ROOT) : rootTagBstring, traverseRecordAndGenerateXml(
                                value, allNamespaces, getEmptyStringMap(), options, key, getChildElementType(
                                        referredType, recordKey), isSequenceField, isSequenceField,
                                parentModelGroupInfo, elementInfo, typeMetadataCache),
                        allNamespaces, options, getAttributesMap(value, options, allNamespaces, getEmptyStringMap()));
            }

            if (key.equals(options.get(Constants.TEXT_FIELD_NAME))) {
                if (rootTagBstring.equals(StringUtils.fromString(Constants.EMPTY_STRING))) {
                    rootTagBstring = StringUtils.fromString(Constants.ROOT);
                }
                return CreateElement.createElement(rootTagBstring, getEmptyStringMap(),
                        CreateText.createText(StringUtils.fromString(value.toString())));
            }

            BXml output = getElementFromRecordMember(key,
                    traverseRecordAndGenerateXml(value, allNamespaces, getEmptyStringMap(), options, null,
                            getChildElementType(referredType, recordKey), isSequenceField,
                            isSequenceField, parentModelGroupInfo, elementInfo, typeMetadataCache),
                    allNamespaces, options, getAttributesMap(value, options, allNamespaces, getEmptyStringMap()));
            if (isContainsModelGroup) {
                output = output.children();
            }
            if (rootTag != null) {
                return CreateElement.createElement(rootTagBstring, getEmptyStringMap(), output);
            }
            return output;
        } catch (Exception e) {
            return DiagnosticLog.createXmlError(e.getMessage());
        }
    }

    private static BMap<BString, BString> getEmptyStringMap() {
        return (BMap<BString, BString>) ((BMap<?, ?>) ValueCreator.createMapValue());
    }

    /**
     * String-producing twin of {@link #fromRecordToXml}. Mirrors the tree-building
     * conversion step by step but composes the XML text directly, so peak memory is
     * proportional to the produced text instead of the materialized {@code BXml} tree.
     * Element open tags (names, attributes, namespace declarations, escaping) are
     * produced by serializing an empty element through the exact same code path the
     * tree conversion uses, so the emitted markup stays faithful to {@code toXml}.
     */
    public static Object fromRecordToXmlString(Object jsonValue, BMap<BString, Object> options, BTypedesc typed) {
        try {
            Type type = typed.getDescribingType();
            Type referredType = TypeUtils.getReferredType(type);
            Object rootTag = options.get(StringUtils.fromString(Constants.ROOT_TAG));
            BMap<BString, BString> allNamespaces = getEmptyStringMap();
            IdentityHashMap<Type, TypeMetadata> typeMetadataCache = new IdentityHashMap<>();
            BString rootTagBstring =
                    StringUtils.fromString(rootTag == null ? Constants.EMPTY_STRING : rootTag.toString());

            if (!isSingleRecordMember(jsonValue)) {
                BMap<BString, BString> rootDeclarations = getNamespacesMap(jsonValue, options, getEmptyStringMap());
                addNamespaces(allNamespaces, rootDeclarations);
                StringBuilder out = new StringBuilder();
                traverseRecordAndGenerateXmlString(out, jsonValue, allNamespaces,
                        getEmptyStringMap(), options, null, type, false, false, null, null, typeMetadataCache,
                        rootDeclarations);
                insertElementAround(out, 0, elementShellString(
                        rootTag == null ? StringUtils.fromString(Constants.ROOT) : rootTagBstring,
                        allNamespaces, options,
                        getAttributesMap(jsonValue, options, allNamespaces, getEmptyStringMap()),
                        getEmptyStringMap(), getEmptyStringMap()));
                return StringUtils.fromString(out.toString());
            }

            BMap<BString, Object> jMap = null;
            try {
                jMap = (BMap<BString, Object>) ValueUtils
                        .convert(jsonValue, Constants.JSON_MAP_TYPE);
            } catch (BError e) {
                return jsonValue == null ? StringUtils.fromString(Constants.EMPTY_STRING)
                        : StringUtils.fromString(
                                CreateText.createText(StringUtils.fromString(jsonValue.toString())).toString());
            }

            if (jMap.isEmpty()) {
                return StringUtils.fromString(Constants.EMPTY_STRING);
            }

            BString key = jMap.getKeys()[0];
            String jsonKey = key.getValue();
            TypeMetadata typeMetadata = getTypeMetadata(typeMetadataCache, referredType);
            HashMap<DataUtils.FieldAnnotationValue, String> elementNamesMap = typeMetadata.elementNamesMap;
            ArrayList<String> sequenceFieldNames = typeMetadata.sequenceFieldNames;
            HashMap<String, ModelGroupInfo> modelGroupRelatedFieldNames = typeMetadata.modelGroupRelatedFieldNames;
            HashMap<String, ElementInfo> elementInfoRelatedFieldNames = typeMetadata.elementInfoRelatedFieldNames;

            boolean isKeyContainsPrefix = jsonKey.contains(Constants.COLON);
            Object value = ToArray.toArray(jMap).getValues()[0];
            addNamespaces(allNamespaces, getNamespacesMap(value, options, getEmptyStringMap()));
            String localJsonKeyPart = getElementLocalKeyPart(isKeyContainsPrefix, jsonKey);
            DataUtils.FieldAnnotationValue jsonKeyFieldAnnotation = getElementNamesMapKey(
                    isKeyContainsPrefix, jsonKey, allNamespaces, localJsonKeyPart);

            String recordKey = elementNamesMap.getOrDefault(jsonKeyFieldAnnotation, localJsonKeyPart);
            boolean isSequenceField = sequenceFieldNames.contains(recordKey);
            boolean isContainsModelGroup = modelGroupRelatedFieldNames.containsKey(recordKey);
            ModelGroupInfo parentModelGroupInfo = modelGroupRelatedFieldNames.get(recordKey);
            ElementInfo elementInfo = elementInfoRelatedFieldNames.get(recordKey);

            if (value instanceof BArray) {
                StringBuilder out = new StringBuilder();
                traverseRecordAndGenerateXmlString(out, value, allNamespaces, getEmptyStringMap(),
                        options, key, getChildElementType(referredType, recordKey), isSequenceField, isSequenceField,
                        parentModelGroupInfo, elementInfo, typeMetadataCache,
                        getNamespacesMap(value, options, getEmptyStringMap()));
                insertElementAround(out, 0, elementShellString(rootTag == null
                                ? StringUtils.fromString(Constants.ROOT) : rootTagBstring,
                        allNamespaces, options, getAttributesMap(value, options, allNamespaces, getEmptyStringMap()),
                        getEmptyStringMap(), getEmptyStringMap()));
                return StringUtils.fromString(out.toString());
            }

            if (key.equals(options.get(Constants.TEXT_FIELD_NAME))) {
                if (rootTagBstring.equals(StringUtils.fromString(Constants.EMPTY_STRING))) {
                    rootTagBstring = StringUtils.fromString(Constants.ROOT);
                }
                return StringUtils.fromString(spliceChildrenIntoElement(
                        CreateElement.createElement(rootTagBstring, getEmptyStringMap(),
                                ValueCreator.createXmlValue(Constants.EMPTY_STRING)).toString(),
                        textString(value.toString())));
            }

            StringBuilder out = new StringBuilder();
            traverseRecordAndGenerateXmlString(out, value, allNamespaces, getEmptyStringMap(),
                    options, null, getChildElementType(referredType, recordKey), isSequenceField,
                    isSequenceField, parentModelGroupInfo, elementInfo, typeMetadataCache,
                    getNamespacesMap(value, options, getEmptyStringMap()));
            String shell = elementShellString(key, allNamespaces, options,
                    getAttributesMap(value, options, allNamespaces, getEmptyStringMap()), getEmptyStringMap(),
                    getEmptyStringMap());
            if (!isContainsModelGroup) {
                insertElementAround(out, 0, shell);
            }
            if (rootTag != null) {
                insertElementAround(out, 0, CreateElement.createElement(rootTagBstring, getEmptyStringMap(),
                        ValueCreator.createXmlValue(Constants.EMPTY_STRING)).toString());
            }
            return StringUtils.fromString(out.toString());
        } catch (Exception e) {
            return DiagnosticLog.createXmlError(e.getMessage());
        }
    }

    /**
     * String-producing twin of {@link #traverseRecordAndGenerateXml}: walks the value in
     * the same order and writes the children's markup directly into the shared builder.
     * Elements are wrapped in place via {@link #insertElementAround}, so no intermediate
     * {@code BXml} nodes or per-level string copies are created.
     *
     * @param out               the shared builder the markup is written into
     * @param jNode             the value whose children are being converted
     * @param allNamespaces     all namespace declarations seen so far (mutated)
     * @param parentNamespaces  namespace declarations in scope from the parent chain
     * @param options           the JSON-to-XML conversion options
     * @param keyObj            the field key for array traversals, or {@code null}
     * @param type              the declared type of {@code jNode}
     * @param isParentSequence  whether the parent field carries an XSD sequence annotation
     * @param isParentSequenceArray whether the parent is a sequence-annotated array
     * @param parentModelGroupInfo  the parent's XSD model group metadata, if any
     * @param parentElementInfo the parent's XSD element metadata, if any
     * @param typeMetadataCache the per-conversion type metadata cache
     * @param rootDeclarations  namespace declarations emitted on the root element
     * @throws BError on XSD occurrence violations
     */
    private static void traverseRecordAndGenerateXmlString(StringBuilder out, Object jNode,
            BMap<BString, BString> allNamespaces,
            BMap<BString, BString> parentNamespaces, BMap<BString, Object> options, Object keyObj, Type type,
            boolean isParentSequence, boolean isParentSequenceArray,
            ModelGroupInfo parentModelGroupInfo, ElementInfo parentElementInfo,
            IdentityHashMap<Type, TypeMetadata> typeMetadataCache,
            BMap<BString, BString> rootDeclarations) throws BError {
        BMap<BString, BString> namespacesOfElem;
        String attributePrefix = options.get(Constants.ATTRIBUTE_PREFIX).toString();
        Type referredType = TypeUtils.getReferredType(type);
        TypeMetadata typeMetadata = getTypeMetadata(typeMetadataCache, referredType);
        HashMap<DataUtils.FieldAnnotationValue, String> elementNamesMap = typeMetadata.elementNamesMap;
        HashMap<String, ModelGroupInfo> modelGroupRelatedFieldNames = typeMetadata.modelGroupRelatedFieldNames;
        HashMap<String, ElementInfo> elementInfoRelatedFieldNames = typeMetadata.elementInfoRelatedFieldNames;
        ArrayList<String> sequenceFieldNames = typeMetadata.sequenceFieldNames;

        if (jNode instanceof BMap jMap) {
            BMap<BString, Object> mapNode = (BMap<BString, Object>) jMap;
            BString[] orderedRecordKeysIfXsdSequencePresent = DataUtils.getOrderedRecordKeysIfXsdSequencePresent(
                    mapNode, isParentSequence ? typeMetadata.xsdSequencePriorityOrderWhenInSequence
                            : DataUtils.getXsdSequencePriorityOrder(referredType, false), referredType);

            if (parentModelGroupInfo instanceof ChoiceInfo) {
                validateChoiceFields(parentModelGroupInfo, jMap, elementInfoRelatedFieldNames,
                        elementNamesMap, options, parentNamespaces);
            }

            for (BString k : orderedRecordKeysIfXsdSequencePresent) {
                Object value = mapNode.get(k);
                String jsonKey = k.getValue().trim();
                boolean isKeyContainsPrefix = jsonKey.contains(Constants.COLON);
                namespacesOfElem = getNamespacesMap(value, options, parentNamespaces);
                String localJsonKeyPart = getElementLocalKeyPart(isKeyContainsPrefix, jsonKey);
                DataUtils.FieldAnnotationValue jsonKeyFieldAnnotation = getElementNamesMapKey(
                        isKeyContainsPrefix, jsonKey, namespacesOfElem, localJsonKeyPart);

                String recordKey = elementNamesMap.getOrDefault(jsonKeyFieldAnnotation, localJsonKeyPart);
                boolean isContainsModelGroup = modelGroupRelatedFieldNames.containsKey(recordKey);
                ModelGroupInfo modelGroupInfo = modelGroupRelatedFieldNames.get(recordKey);
                ElementInfo elementInfo = elementInfoRelatedFieldNames.get(recordKey);
                boolean isSequenceField = sequenceFieldNames.contains(recordKey);

                if (jsonKey.startsWith(attributePrefix)) {
                    continue;
                }

                if (jsonKey.equals(options.get(Constants.TEXT_FIELD_NAME).toString())) {
                    out.append(textString(value.toString()));
                } else {
                    addNamespaces(allNamespaces, namespacesOfElem);
                    if (value instanceof BArray) {
                        BString keyToPass = isAnyArrayFieldKey(referredType, recordKey, value)
                                ? StringUtils.fromString("@Any:" + k.getValue()) : k;
                        traverseRecordAndGenerateXmlString(out, value, allNamespaces, namespacesOfElem,
                                options, keyToPass, getChildElementType(referredType, recordKey),
                                isSequenceField, isSequenceField, modelGroupInfo, elementInfo, typeMetadataCache,
                                rootDeclarations);
                    } else {
                        BString elementKey = resolveAnyAnnotatedElementKey(referredType, recordKey, k);
                        int mark = out.length();
                        traverseRecordAndGenerateXmlString(out, value, allNamespaces, namespacesOfElem,
                                options, null, getChildElementType(referredType, recordKey), isSequenceField,
                                isSequenceField, modelGroupInfo, elementInfo, typeMetadataCache, rootDeclarations);
                        String shell = elementShellString(elementKey, allNamespaces, options,
                                getAttributesMap(value, options, allNamespaces, parentNamespaces), parentNamespaces,
                                rootDeclarations);
                        if (!isContainsModelGroup || isParentSequenceArray) {
                            insertElementAround(out, mark, shell);
                        }
                    }
                }
            }
        } else if (jNode instanceof BArray arrayNode) {
            int size = arrayNode.size();
            if (isParentSequenceArray && parentModelGroupInfo != null && parentModelGroupInfo instanceof SequenceInfo) {
                if (size < parentModelGroupInfo.getMinOccurs()) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_LESS_THAN_MIN_REQUIRED_TIMES,
                            parentModelGroupInfo.getFieldName());
                }

                if (size > parentModelGroupInfo.getMaxOccurs()) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_MORE_THAN_MAX_ALLOWED_TIMES,
                            parentModelGroupInfo.getFieldName());
                }
            } else {
                if (parentElementInfo != null && size > parentElementInfo.maxOccurs) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_MORE_THAN_MAX_ALLOWED_TIMES,
                            parentElementInfo.fieldName);
                }

                if (parentElementInfo != null && size < parentElementInfo.minOccurs) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_LESS_THAN_MIN_REQUIRED_TIMES,
                            parentElementInfo.fieldName);
                }
            }

            for (Object i : arrayNode.getValues()) {
                if (i == null) {
                    continue;
                }
                String arrayEntryTagKey = Constants.EMPTY_STRING;
                if (keyObj instanceof BString key) {
                    arrayEntryTagKey = key.getValue();
                } else if (!options.get(Constants.ARRAY_ENTRY_TAG).toString().isEmpty()) {
                    arrayEntryTagKey = options.get(Constants.ARRAY_ENTRY_TAG).toString();
                }

                namespacesOfElem = getNamespacesMap(i, options, parentNamespaces);
                addNamespaces(allNamespaces, namespacesOfElem);
                int mark = out.length();
                String shell;
                if (options.get(Constants.ARRAY_ENTRY_TAG).toString().isEmpty()) {
                    Type childType = getChildElementType(referredType, null);
                    traverseRecordAndGenerateXmlString(out, i, allNamespaces, namespacesOfElem,
                            options, keyObj, childType,
                            isParentSequence, isParentSequenceArray, parentModelGroupInfo, parentElementInfo,
                            typeMetadataCache, rootDeclarations);
                    String elementTagKey = arrayEntryTagKey;
                    boolean isAnyAnnotatedField = keyObj instanceof BString fieldNameBString &&
                            fieldNameBString.getValue().startsWith("@Any:");

                    if (isAnyAnnotatedField && i instanceof BMap) {
                        Type elementValueType = TypeUtils.getType(i);
                        Type referredElementType = TypeUtils.getReferredType(elementValueType);
                        if (referredElementType instanceof RecordType recordValueType) {
                            elementTagKey = getRecordTypeName(recordValueType);
                        } else {
                            // Fallback to declared child type if runtime type is not a RecordType
                            Type referredChildType = TypeUtils.getReferredType(childType);
                            if (referredChildType instanceof RecordType recordChildType) {
                                elementTagKey = getRecordTypeName(recordChildType);
                            }
                        }
                    }
                    shell = elementShellString(StringUtils.fromString(elementTagKey),
                            allNamespaces, options, getAttributesMap(i, options, allNamespaces, parentNamespaces),
                            parentNamespaces, rootDeclarations);
                } else {
                    traverseRecordAndGenerateXmlString(out, i, allNamespaces, namespacesOfElem,
                            options, null, getChildElementType(referredType, null),
                            isParentSequence, isParentSequenceArray, parentModelGroupInfo, parentElementInfo,
                            typeMetadataCache, rootDeclarations);
                    shell = elementShellString(StringUtils.fromString(arrayEntryTagKey),
                            allNamespaces, options, getAttributesMap(i, options, allNamespaces, parentNamespaces),
                            parentNamespaces, rootDeclarations);
                }
                if (!isParentSequenceArray) {
                    insertElementAround(out, mark, shell);
                }
            }
        } else {
            out.append(textString(StringUtils.getStringValue(jNode)));
        }
    }

    /**
     * Builds an element's serialized "shell" — the element with no children — through the
     * exact name/attribute/namespace logic of {@link #getElementFromRecordMember}. The
     * already-serialized children are later placed inside it by
     * {@link #insertElementAround}.
     */
    private static String elementShellString(BString name, BMap<BString, BString> namespaces,
            BMap<BString, Object> options, BMap<BString, BString> attributes,
            BMap<BString, BString> nearestScopeNamespaces, BMap<BString, BString> rootScopeNamespaces) {
        // Fast path for the common case: no attributes, no prefix, plain name, no name
        // rewriting configured. The full path builds an XML element value and runs the
        // serializer, which allocates heavily (element, attribute map, type objects) —
        // for an attribute-less simple name the serialized form is fixed.
        String nameStr = name.getValue();
        if (attributes.isEmpty() && isPlainElementName(nameStr)
                && options.get(Constants.USER_ATTRIBUTE_PREFIX).toString().isEmpty()
                && !nameStr.startsWith(options.get(Constants.ATTRIBUTE_PREFIX).toString())) {
            return "<" + nameStr + "/>";
        }
        BXml emptyElement = getElementFromRecordMember(name, ValueCreator.createXmlValue(Constants.EMPTY_STRING),
                namespaces, options, attributes);
        return serializeWithinScope(emptyElement, nearestScopeNamespaces, rootScopeNamespaces);
    }

    /**
     * Reports whether an element name is emitted verbatim by the serializer: a letter or
     * underscore followed by letters, digits, {@code _}, {@code .} or {@code -}. Names
     * outside this conservative subset take the full element-construction path.
     *
     * @param name the element name to check
     * @return true if the serialized form of the name is the name itself
     */
    private static boolean isPlainElementName(String name) {
        if (name.isEmpty()) {
            return false;
        }
        char first = name.charAt(0);
        if (!(Character.isLetter(first) || first == '_')) {
            return false;
        }
        for (int i = 1; i < name.length(); i++) {
            char c = name.charAt(i);
            if (!(Character.isLetterOrDigit(c) || c == '_' || c == '.' || c == '-')) {
                return false;
            }
        }
        return true;
    }

    /**
     * Wraps the builder content from {@code mark} onward in the given element shell,
     * inserting the open tag at {@code mark} and appending the close tag — so children
     * are written once into a single shared builder instead of being copied at every
     * nesting level.
     */
    private static void insertElementAround(StringBuilder out, int mark, String shellString) {
        if (out.length() == mark) {
            out.append(shellString);
            return;
        }
        if (shellString.endsWith("/>")) {
            int nameEnd = 1;
            while (nameEnd < shellString.length()) {
                char c = shellString.charAt(nameEnd);
                if (c == ' ' || c == '/' || c == '>' || c == '\t' || c == '\n' || c == '\r') {
                    break;
                }
                nameEnd++;
            }
            String qualifiedName = shellString.substring(1, nameEnd);
            out.insert(mark, ">").insert(mark, shellString.substring(0, shellString.length() - 2));
            out.append("</").append(qualifiedName).append(">");
            return;
        }
        // <tag ...></tag> form: '<' never occurs unescaped inside attribute values, so the
        // first "></" is the boundary between the open and close tags.
        int boundary = shellString.indexOf("></");
        if (boundary == -1) {
            throw new IllegalStateException("unexpected empty element serialization: " + shellString);
        }
        out.insert(mark, shellString.substring(0, boundary + 1));
        out.append(shellString.substring(boundary + 1));
    }

    /**
     * Serializes an element as it would appear under ancestors that declare the given
     * namespaces: the element is placed inside a synthetic wrapper element carrying the
     * in-scope declarations, so the runtime serializer itself suppresses duplicate xmlns
     * attributes — exactly as it does when a whole tree is serialized — and the wrapper
     * tags are then stripped. The nearest scope wins over the root element's declarations.
     */
    private static String serializeWithinScope(BXml element, BMap<BString, BString> nearestScope,
            BMap<BString, BString> rootScope) {
        if (nearestScope.isEmpty() && rootScope.isEmpty()) {
            return element.toString();
        }
        BMap<BString, BString> scopeDeclarations = getEmptyStringMap();
        putScopeDeclarations(scopeDeclarations, rootScope);
        putScopeDeclarations(scopeDeclarations, nearestScope);
        BXml wrapper = CreateElement.createElement(StringUtils.fromString("w"), scopeDeclarations, element);
        String serialized = wrapper.toString();
        int openTagEnd = serialized.indexOf('>');
        return serialized.substring(openTagEnd + 1, serialized.length() - "</w>".length());
    }

    /**
     * Copies namespace declarations into an attribute map for element creation. The
     * default namespace is keyed as {@code {xmlns-uri}} (empty local part) in scope maps
     * and must be stored under the plain {@code xmlns} attribute name, as
     * {@link #getElementFromRecordMember} does for regular elements.
     */
    private static void putScopeDeclarations(BMap<BString, BString> target, BMap<BString, BString> scope) {
        String xmlnsNameUri = getXmlnsNameUrI();
        for (Map.Entry<BString, BString> declaration : scope.entrySet()) {
            BString declarationKey = declaration.getKey();
            target.put(declarationKey.getValue().equals(xmlnsNameUri) ? XMLNS : declarationKey,
                    declaration.getValue());
        }
    }

    /**
     * Serializes text exactly as it appears inside an element in a serialized tree
     * (standalone text serialization escapes additional characters, e.g. {@code >}),
     * by wrapping it in a single-character element and stripping the wrapper tags.
     */
    private static String textString(String textValue) {
        if (textValue.isEmpty()) {
            return Constants.EMPTY_STRING;
        }
        // Fast path: text without characters the serializer escapes (or may escape) is
        // emitted verbatim. Anything else takes the exact serializer round trip.
        boolean needsEscaping = false;
        for (int i = 0; i < textValue.length(); i++) {
            char c = textValue.charAt(i);
            if (c == '&' || c == '<' || c == '>' || c == '\r' || c == '\n' || c == '"' || c == '\'') {
                needsEscaping = true;
                break;
            }
        }
        if (!needsEscaping) {
            return textValue;
        }
        String wrapped = CreateElement.createElement(StringUtils.fromString("x"), getEmptyStringMap(),
                CreateText.createText(StringUtils.fromString(textValue))).toString();
        return wrapped.substring(3, wrapped.length() - 4);
    }

    /**
     * Places already-serialized children inside a serialized empty element, handling both
     * the self-closing and the open/close-pair serialized forms.
     *
     * @param emptyElementString the serialized element with no children
     * @param childrenString     the serialized children markup
     * @return the serialized element containing the children
     */
    private static String spliceChildrenIntoElement(String emptyElementString, String childrenString) {
        if (childrenString.isEmpty()) {
            return emptyElementString;
        }
        if (emptyElementString.endsWith("/>")) {
            int nameEnd = 1;
            while (nameEnd < emptyElementString.length()) {
                char c = emptyElementString.charAt(nameEnd);
                if (c == ' ' || c == '/' || c == '>' || c == '\t' || c == '\n' || c == '\r') {
                    break;
                }
                nameEnd++;
            }
            String qualifiedName = emptyElementString.substring(1, nameEnd);
            return emptyElementString.substring(0, emptyElementString.length() - 2) + ">" + childrenString
                    + "</" + qualifiedName + ">";
        }
        // <tag ...></tag> form: '<' never occurs unescaped inside attribute values, so the
        // first "></" is the boundary between the open and close tags.
        int boundary = emptyElementString.indexOf("></");
        if (boundary == -1) {
            throw new IllegalStateException("unexpected empty element serialization: " + emptyElementString);
        }
        return emptyElementString.substring(0, boundary + 1) + childrenString
                + emptyElementString.substring(boundary + 1);
    }

    /**
     * Converts a value's children to XML nodes. Kept for API compatibility: delegates to
     * the cached variant with a fresh per-call type metadata cache.
     *
     * @param jNode             the value whose children are being converted
     * @param allNamespaces     all namespace declarations seen so far (mutated)
     * @param parentNamespaces  namespace declarations in scope from the parent chain
     * @param options           the JSON-to-XML conversion options
     * @param keyObj            the field key for array traversals, or {@code null}
     * @param type              the declared type of {@code jNode}
     * @param isParentSequence  whether the parent field carries an XSD sequence annotation
     * @param isParentSequenceArray whether the parent is a sequence-annotated array
     * @param parentModelGroupInfo  the parent's XSD model group metadata, if any
     * @param parentElementInfo the parent's XSD element metadata, if any
     * @return the children of the element being built, as an XML sequence
     * @throws BError on XSD occurrence violations
     */
    public static BXml traverseRecordAndGenerateXml(Object jNode, BMap<BString, BString> allNamespaces,
            BMap<BString, BString> parentNamespaces, BMap<BString, Object> options, Object keyObj, Type type,
            boolean isParentSequence, boolean isParentSequenceArray,
            ModelGroupInfo parentModelGroupInfo, ElementInfo parentElementInfo) throws BError {
        return traverseRecordAndGenerateXml(jNode, allNamespaces, parentNamespaces, options, keyObj, type,
                isParentSequence, isParentSequenceArray, parentModelGroupInfo, parentElementInfo,
                new IdentityHashMap<>());
    }

    private static BXml traverseRecordAndGenerateXml(Object jNode, BMap<BString, BString> allNamespaces,
            BMap<BString, BString> parentNamespaces, BMap<BString, Object> options, Object keyObj, Type type,
            boolean isParentSequence, boolean isParentSequenceArray,
            ModelGroupInfo parentModelGroupInfo, ElementInfo parentElementInfo,
            IdentityHashMap<Type, TypeMetadata> typeMetadataCache) throws BError {
        BMap<BString, BString> namespacesOfElem;
        BXml xNode = ValueCreator.createXmlValue(Constants.EMPTY_STRING);
        String attributePrefix = options.get(Constants.ATTRIBUTE_PREFIX).toString();
        Type referredType = TypeUtils.getReferredType(type);
        TypeMetadata typeMetadata = getTypeMetadata(typeMetadataCache, referredType);
        HashMap<DataUtils.FieldAnnotationValue, String> elementNamesMap = typeMetadata.elementNamesMap;
        HashMap<String, ModelGroupInfo> modelGroupRelatedFieldNames = typeMetadata.modelGroupRelatedFieldNames;
        HashMap<String, ElementInfo> elementInfoRelatedFieldNames = typeMetadata.elementInfoRelatedFieldNames;
        ArrayList<String> sequenceFieldNames = typeMetadata.sequenceFieldNames;
        // Children are collected in a list and concatenated once at the end: folding with
        // Concat.concat per child re-copies all previously accumulated children on every
        // append, which is O(n^2) in the number of children.
        List<Object> childParts = new ArrayList<>();
        BXml childElement;

        if (jNode instanceof BMap jMap) {
            BMap<BString, Object> mapNode = (BMap<BString, Object>) jMap;
            BString[] orderedRecordKeysIfXsdSequencePresent = DataUtils.getOrderedRecordKeysIfXsdSequencePresent(
                    mapNode, isParentSequence ? typeMetadata.xsdSequencePriorityOrderWhenInSequence
                            : DataUtils.getXsdSequencePriorityOrder(referredType, false), referredType);

            if (parentModelGroupInfo instanceof ChoiceInfo) {
                validateChoiceFields(parentModelGroupInfo, jMap, elementInfoRelatedFieldNames,
                        elementNamesMap, options, parentNamespaces);
            }

            for (BString k : orderedRecordKeysIfXsdSequencePresent) {
                Object value = mapNode.get(k);
                String jsonKey = k.getValue().trim();
                boolean isKeyContainsPrefix = jsonKey.contains(Constants.COLON);
                namespacesOfElem = getNamespacesMap(value, options, parentNamespaces);
                String localJsonKeyPart = getElementLocalKeyPart(isKeyContainsPrefix, jsonKey);
                DataUtils.FieldAnnotationValue jsonKeyFieldAnnotation = getElementNamesMapKey(
                        isKeyContainsPrefix, jsonKey, namespacesOfElem, localJsonKeyPart);

                String recordKey = elementNamesMap.getOrDefault(jsonKeyFieldAnnotation, localJsonKeyPart);
                boolean isContainsModelGroup = modelGroupRelatedFieldNames.containsKey(recordKey);
                ModelGroupInfo modelGroupInfo = modelGroupRelatedFieldNames.get(recordKey);
                ElementInfo elementInfo = elementInfoRelatedFieldNames.get(recordKey);
                boolean isSequenceField = sequenceFieldNames.contains(recordKey);

                if (jsonKey.startsWith(attributePrefix)) {
                    continue;
                }

                if (jsonKey.equals(options.get(Constants.TEXT_FIELD_NAME).toString())) {
                    childParts.add(CreateText.createText(StringUtils.fromString(value.toString())));
                } else {
                    addNamespaces(allNamespaces, namespacesOfElem);
                    if (value instanceof BArray) {
                        BString keyToPass = isAnyArrayFieldKey(referredType, recordKey, value)
                                ? StringUtils.fromString("@Any:" + k.getValue()) : k;

                        childElement = traverseRecordAndGenerateXml(value, allNamespaces, namespacesOfElem, options,
                                keyToPass,
                                getChildElementType(referredType, recordKey),
                                isSequenceField, isSequenceField, modelGroupInfo, elementInfo, typeMetadataCache);
                        childParts.add(childElement);
                    } else {
                        BString elementKey = resolveAnyAnnotatedElementKey(referredType, recordKey, k);
                        childElement = getElementFromRecordMember(elementKey, traverseRecordAndGenerateXml(
                                value, allNamespaces, namespacesOfElem, options, null, getChildElementType(
                            referredType, recordKey), isSequenceField, isSequenceField, modelGroupInfo, elementInfo,
                            typeMetadataCache),
                            allNamespaces, options, getAttributesMap(value, options, allNamespaces, parentNamespaces));
                        childParts.add(!isContainsModelGroup || isParentSequenceArray ? childElement
                                : childElement.children());
                    }
                }
            }
        } else if (jNode instanceof BArray arrayNode) {
            int size = arrayNode.size();
            if (isParentSequenceArray && parentModelGroupInfo != null && parentModelGroupInfo instanceof SequenceInfo) {
                if (size < parentModelGroupInfo.getMinOccurs()) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_LESS_THAN_MIN_REQUIRED_TIMES,
                            parentModelGroupInfo.getFieldName());
                }

                if (size > parentModelGroupInfo.getMaxOccurs()) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_MORE_THAN_MAX_ALLOWED_TIMES,
                            parentModelGroupInfo.getFieldName());
                }
            } else {
                if (parentElementInfo != null && size > parentElementInfo.maxOccurs) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_MORE_THAN_MAX_ALLOWED_TIMES,
                            parentElementInfo.fieldName);
                }

                if (parentElementInfo != null && size < parentElementInfo.minOccurs) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_LESS_THAN_MIN_REQUIRED_TIMES,
                            parentElementInfo.fieldName);
                }
            }

            for (Object i : arrayNode.getValues()) {
                if (i == null) {
                    continue;
                }
                String arrayEntryTagKey = Constants.EMPTY_STRING;
                if (keyObj instanceof BString key) {
                    arrayEntryTagKey = key.getValue();
                } else if (!options.get(Constants.ARRAY_ENTRY_TAG).toString().isEmpty()) {
                    arrayEntryTagKey = options.get(Constants.ARRAY_ENTRY_TAG).toString();
                }

                namespacesOfElem = getNamespacesMap(i, options, parentNamespaces);
                addNamespaces(allNamespaces, namespacesOfElem);
                if (options.get(Constants.ARRAY_ENTRY_TAG).toString().isEmpty()) {
                    Type childType = getChildElementType(referredType, null);
                    BXml inner = traverseRecordAndGenerateXml(i, allNamespaces, namespacesOfElem,
                            options, keyObj, childType,
                            isParentSequence, isParentSequenceArray, parentModelGroupInfo, parentElementInfo,
                            typeMetadataCache);
                    String elementTagKey = arrayEntryTagKey;
                    boolean isAnyAnnotatedField = keyObj instanceof BString fieldNameBString && 
                            fieldNameBString.getValue().startsWith("@Any:");
                    
                    if (isAnyAnnotatedField && i instanceof BMap) {
                        String actualFieldName = ((BString) keyObj).getValue().substring("@Any:".length());
                        arrayEntryTagKey = actualFieldName;
                        Type elementValueType = TypeUtils.getType(i);
                        Type referredElementType = TypeUtils.getReferredType(elementValueType);
                        if (referredElementType instanceof RecordType recordValueType) {
                            elementTagKey = getRecordTypeName(recordValueType);
                        } else {
                            // Fallback to declared child type if runtime type is not a RecordType
                            Type referredChildType = TypeUtils.getReferredType(childType);
                            if (referredChildType instanceof RecordType recordChildType) {
                                elementTagKey = getRecordTypeName(recordChildType);
                            }
                        }
                    }
                    childElement = getElementFromRecordMember(StringUtils.fromString(elementTagKey),
                        inner,
                        allNamespaces, options, getAttributesMap(i, options, allNamespaces, parentNamespaces));
                } else {
                    childElement = getElementFromRecordMember(StringUtils.fromString(arrayEntryTagKey),
                        traverseRecordAndGenerateXml(i, allNamespaces, namespacesOfElem,
                                options, null, getChildElementType(referredType, null),
                                isParentSequence, isParentSequenceArray, parentModelGroupInfo, parentElementInfo,
                                typeMetadataCache),
                        allNamespaces, options, getAttributesMap(i, options, allNamespaces, parentNamespaces));
                }
                childParts.add(isParentSequenceArray ? childElement.children() : childElement);
            }
        } else {
            xNode = CreateText.createText(StringUtils.fromString(StringUtils.getStringValue(jNode)));
        }
        if (!childParts.isEmpty()) {
            xNode = Concat.concat(childParts.toArray());
        }
        return xNode;
    }

    /**
     * Reports whether an array-valued field annotated with {@code @xmldata:Any} holds
     * record elements, in which case the array traversal names each element after its
     * runtime record type instead of the field key.
     *
     * @param referredType the record type owning the field
     * @param recordKey    the field name
     * @param value        the array value of the field
     * @return true if the field is {@code @Any}-annotated and holds record elements
     */
    private static boolean isAnyArrayFieldKey(Type referredType, String recordKey, Object value) {
        if (!DataUtils.isFieldAnnotatedWithAny(referredType, recordKey)) {
            return false;
        }
        Type childElementType = getChildElementType(referredType, recordKey);
        Type referredChildType = TypeUtils.getReferredType(childElementType);
        if (referredChildType.getTag() == TypeTags.ARRAY_TAG) {
            ArrayType arrayType = (ArrayType) referredChildType;
            Type elementType = TypeUtils.getReferredType(arrayType.getElementType());
            if (elementType.getTag() == TypeTags.RECORD_TYPE_TAG) {
                return true;
            } else if (elementType.getTag() == TypeTags.ANYDATA_TAG) {
                BArray array = (BArray) value;
                for (int i = 0; i < array.size(); i++) {
                    Object element = array.get(i);
                    if (element != null) {
                        Type actualType = TypeUtils.getType(element);
                        if (TypeUtils.getReferredType(actualType).getTag() == TypeTags.RECORD_TYPE_TAG) {
                            return true;
                        }
                    }
                }
            }
        } else if (referredChildType.getTag() == TypeTags.UNION_TAG) {
            UnionType unionType = (UnionType) referredChildType;
            for (Type memberType : unionType.getMemberTypes()) {
                Type referredMemberType = TypeUtils.getReferredType(memberType);
                if (referredMemberType.getTag() == TypeTags.ARRAY_TAG) {
                    ArrayType arrayType = (ArrayType) referredMemberType;
                    Type elementType = TypeUtils.getReferredType(arrayType.getElementType());
                    if (elementType.getTag() == TypeTags.ANYDATA_TAG &&
                            TypeUtils.getType(value).getTag() == TypeTags.ARRAY_TAG) {
                        BArray array = (BArray) value;
                        if (array.size() > 0) {
                            for (int i = 0; i < array.size(); i++) {
                                Object element = array.get(i);
                                if (element != null) {
                                    Type actualType = TypeUtils.getType(element);
                                    if (TypeUtils.getReferredType(actualType).getTag() == TypeTags.RECORD_TYPE_TAG) {
                                        return true;
                                    }
                                }
                            }
                        }
                    }
                    break;
                }
            }
        }
        return false;
    }

    /**
     * Resolves the element name for a field annotated with {@code @xmldata:Any}: the name
     * of the record type of the value (or of the first record member of a union field
     * type), falling back to the field key when no record type applies.
     *
     * @param referredType the record type owning the field
     * @param recordKey    the field name
     * @param k            the original field key
     * @return the element name to emit for the field
     */
    private static BString resolveAnyAnnotatedElementKey(Type referredType, String recordKey, BString k) {
        BString elementKey = k;
        if (referredType instanceof RecordType recordType &&
                DataUtils.isFieldAnnotatedWithAny(recordType, recordKey)) {
            RecordType recordValueType = null;

            Type childType = getChildElementType(referredType, recordKey);
            Type referredChildType = TypeUtils.getReferredType(childType);
            if (referredChildType instanceof RecordType) {
                recordValueType = (RecordType) referredChildType;
            } else if (referredChildType instanceof UnionType unionType) {
                for (Type memberType : unionType.getMemberTypes()) {
                    Type referredMemberType = TypeUtils.getReferredType(memberType);
                    if (referredMemberType instanceof RecordType) {
                        recordValueType = (RecordType) referredMemberType;
                        break;
                    }
                }
            }

            if (recordValueType != null) {
                String typeName = getRecordTypeName(recordValueType);
                elementKey = StringUtils.fromString(typeName);
            }
        }
        return elementKey;
    }

    private static void validateChoiceFields(ModelGroupInfo parentModelGroupInfo, BMap jMap,
                                             HashMap<String, ElementInfo> elementInfoRelatedFieldNames,
                                             HashMap<DataUtils.FieldAnnotationValue, String> elementNamesMap,
                                             BMap<BString, Object> options, BMap<BString, BString> parentNamespaces) {
        // TODO: Update this later for validate choices with multiple element occurences.
        boolean isMeasurable = true;
        int occurences = 0;

        for (Object key : jMap.getKeys()) {
            String jsonKey = key.toString();
            Object value = jMap.get(key);
            boolean isKeyContainsPrefix = jsonKey.contains(Constants.COLON);
            BMap<BString, BString> namespacesMap = getNamespacesMap(value, options, parentNamespaces);
            String localJsonKeyPart = getElementLocalKeyPart(isKeyContainsPrefix, jsonKey);
            DataUtils.FieldAnnotationValue jsonKeyFieldAnnotation = getElementNamesMapKey(
                    isKeyContainsPrefix, jsonKey, namespacesMap, localJsonKeyPart);

            String recordKey = elementNamesMap.getOrDefault(jsonKeyFieldAnnotation, localJsonKeyPart);
            ElementInfo elementInfo = elementInfoRelatedFieldNames.get(recordKey);
            if (elementInfo != null && elementInfo.maxOccurs != 1) {
                isMeasurable = false;
                break;
            }

            if (value instanceof BArray array) {
                occurences += array.size();
            } else {
                occurences++;
            }
        }

        if (isMeasurable && occurences > parentModelGroupInfo.getMaxOccurs()) {
            throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_MORE_THAN_MAX_ALLOWED_TIMES,
                    parentModelGroupInfo.getFieldName());
        }

        if (isMeasurable && occurences < parentModelGroupInfo.getMinOccurs()) {
            throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_LESS_THAN_MIN_REQUIRED_TIMES,
                    parentModelGroupInfo.getFieldName());
        }
    }

    private static DataUtils.FieldAnnotationValue getElementNamesMapKey(boolean isKeyContainsPrefix, String jsonKey,
                                            BMap<BString, BString> namespacesMap, String localJsonKeyPart) {
        if (isKeyContainsPrefix) {
            int jsonKeyIndex = jsonKey.indexOf(Constants.COLON);
            String prefix = jsonKey.substring(0, jsonKeyIndex);
            BString namespaceUrl = namespacesMap.get(StringUtils.fromString(getXmlnsNameUrI() + prefix));
            String namespaceUrlStr = namespaceUrl != null ? namespaceUrl.getValue() : null;
            return new DataUtils.FieldAnnotationValue(localJsonKeyPart, namespaceUrlStr);
        }

        return new DataUtils.FieldAnnotationValue(jsonKey, null);
    }

    private static String getElementLocalKeyPart(boolean isKeyContainsPrefix, String jsonKey) {
        return isKeyContainsPrefix ? jsonKey.substring(jsonKey.indexOf(Constants.COLON) + 1) : jsonKey;
    }

    private static HashMap<String, ModelGroupInfo> getModelGroupRelatedFieldNames(Type expType,
                                                  HashMap<DataUtils.FieldAnnotationValue, String> elementNamesMap) {
        Type referedType = TypeUtils.getReferredType(expType);
        if (referedType instanceof RecordType recordType) {
            return DataUtils.getFieldNamesWithModelGroupAnnotations(recordType, elementNamesMap);
        }
        return new HashMap<>();
    }

    private static HashMap<String, ElementInfo> getElementInfoRelatedFieldNames(Type expType) {
        Type referedType = TypeUtils.getReferredType(expType);
        if (referedType instanceof RecordType recordType) {
            return DataUtils.getFieldNamesWithElementGroupAnnotations(recordType);
        }
        return new HashMap<>();
    }

    private static ArrayList<String> getSequenceFieldNames(Type expType) {
        Type referedType = TypeUtils.getReferredType(expType);
        if (referedType instanceof RecordType recordType) {
            return DataUtils.getFieldNamesWithSequenceAnnotations(recordType);
        }
        return new ArrayList<>();
    }


    private static Type getChildElementType(Type type, String recordKey) throws BError {
        try {
            if (type instanceof ArrayType arrayType) {
                return TypeUtils.getReferredType(arrayType.getElementType());
            }

            if (type instanceof RecordType recordType) {
                Map<String, Field> fields = recordType.getFields();
                if (fields.containsKey(recordKey)) {
                    return fields.get(recordKey).getFieldType();
                }

                Optional<String> fieldName = getFieldFromRecordNameAnnotation(fields, recordKey);
                if (!(fieldName.isEmpty()) && fields.containsKey(fieldName.get())) {
                    return fields.get(fieldName.get()).getFieldType();
                }

                Optional<Type> anyFieldType = getTypeFromAnyAnnotatedField(recordType, fields, recordKey);
                if (anyFieldType.isPresent()) {
                    return anyFieldType.get();
                }

                Type restFieldType = recordType.getRestFieldType();
                if (restFieldType != null) {
                    return restFieldType;
                }
                throw DiagnosticLog.createXmlError("Invalid xml provided");
            }
            return type;
        } catch (Exception e) {
            throw DiagnosticLog.createXmlError("Invalid xml provided");
        }
    }

    private static Optional<String> getFieldFromRecordNameAnnotation(Map<String, Field> fields, String recordKey) {
        for (Field field: fields.values()) {
            Type fieldType = TypeUtils.getReferredType(field.getFieldType());
            if (fieldType instanceof RecordType recordType) {
                for (Map.Entry<BString, Object> annotation: recordType.getAnnotations().entrySet()) {
                    if (DataUtils.isNameAnnotationKey(annotation.getKey().getValue())) {
                        String name = ((BMap<BString, Object>) annotation.getValue()).get(Constants.VALUE).toString();
                        if (name.equals(recordKey)) {
                            return Optional.of(field.getFieldName());
                        }
                    }
                }
            }
        }
        return Optional.empty();
    }

    private static Optional<Type> getTypeFromAnyAnnotatedField(RecordType parentRecordType,
                                                                Map<String, Field> fields, String recordKey) {
        for (Field field : fields.values()) {
            if (!DataUtils.isFieldAnnotatedWithAny(parentRecordType, field.getFieldName())) {
                continue;
            }
            Type fieldType = TypeUtils.getReferredType(field.getFieldType());
            if (fieldType.getTag() == TypeTags.UNION_TAG) {
                for (Type memberType : ((UnionType) fieldType).getMemberTypes()) {
                    Type referredMemberType = TypeUtils.getReferredType(memberType);
                    if (referredMemberType.getTag() == TypeTags.RECORD_TYPE_TAG) {
                        String typeName = getRecordTypeName((RecordType) referredMemberType);
                        if (typeName.equals(recordKey)) {
                            return Optional.of(referredMemberType);
                        }
                    }
                }
            } else if (fieldType.getTag() == TypeTags.RECORD_TYPE_TAG) {
                String typeName = getRecordTypeName((RecordType) fieldType);
                if (typeName.equals(recordKey)) {
                    return Optional.of(fieldType);
                }
            } else if (fieldType.getTag() == TypeTags.ANYDATA_TAG || fieldType.getTag() == TypeTags.JSON_TAG) {
                return Optional.of(fieldType);
            }
        }
        return Optional.empty();
    }

    private static String getRecordTypeName(RecordType recordType) {
        for (Map.Entry<BString, Object> annotation : recordType.getAnnotations().entrySet()) {
            if (DataUtils.isNameAnnotationKey(annotation.getKey().getValue())) {
                return ((BMap<BString, Object>) annotation.getValue()).get(Constants.VALUE).toString();
            }
    }
        return recordType.getName();
    }

    /**
     * Reports whether a value converts through the single-member path: maps with at most
     * one entry, scalars, and arrays whose declared element type is not plain {@code json}.
     *
     * @param node the value being converted
     * @return true if the single-member conversion path applies
     */
    public static boolean isSingleRecordMember(Object node) {
        if (node instanceof BArray arrayNode) {
            // Intentionally compares the declared element type without resolving type
            // references, matching the pre-optimization behavior exactly: previously a
            // named-json-alias array failed the JSON_TAG check and then threw inside
            // ValueUtils.convert, which also resulted in true.
            return arrayNode.getElementType().getTag() != TypeTags.JSON_TAG;
        }

        if (node instanceof BMap mapNode) {
            return mapNode.size() <= 1;
        }
        return true;
    }
    public static BXml getElementFromRecordMember(BString name, BXml children, BMap<BString, BString> namespaces,
                                  BMap<BString, Object> options, BMap<BString, BString> attributes) {
        String attributePrefix = options.get(Constants.ATTRIBUTE_PREFIX).toString();
        String userAttributePrefix = options.get(Constants.USER_ATTRIBUTE_PREFIX).toString();
        BXml element;
        String nameStr = name.getValue();
        int index = nameStr.indexOf(Constants.COLON);

        if (index != -1) {
            String prefix = nameStr.substring(0, index);
            String elementName;

            if (!userAttributePrefix.isEmpty()) {
                elementName = removeUserAttributePrefix(StringUtils.fromString(nameStr),
                        StringUtils.fromString(userAttributePrefix), (long) index).getValue();
            } else {
                elementName = nameStr.substring(index + 1, nameStr.length());
            }

            String namespaceUrl = attributes.get(StringUtils.fromString(getXmlnsNameUrI() + prefix)).toString();

            if (namespaceUrl.isEmpty()) {
                namespaceUrl = namespaces.get(StringUtils.fromString(getXmlnsNameUrI() + prefix)).toString();

                if (!namespaceUrl.isEmpty()) {
                    attributes.put(StringUtils.fromString(getXmlnsNameUrI() + prefix),
                            StringUtils.fromString(namespaceUrl));
                }
            }

            if (namespaceUrl.equals(Constants.EMPTY_STRING)) {
                element = CreateElement.createElement(StringUtils.fromString(elementName), attributes, children);
            } else {
                element = CreateElement.createElement(StringUtils.fromString("{" + namespaceUrl + "}" + elementName),
                        attributes, children);
            }
        } else {
            if (nameStr.startsWith(attributePrefix)) {
                throw DiagnosticLog.createXmlError("attribute cannot be an object or array.");
            }

            BMap<BString, BString> newAttributes = attributes;
            String defaultNamespaceUri = Constants.EMPTY_STRING;
            // Check for namespace stored with full namespace URI key
            if (newAttributes.containsKey(StringUtils.fromString(getXmlnsNameUrI()))) {
                String value = newAttributes.get(StringUtils.fromString(getXmlnsNameUrI())).toString();
                newAttributes.remove(StringUtils.fromString(getXmlnsNameUrI()));
                newAttributes.put(XMLNS, StringUtils.fromString(value));
                defaultNamespaceUri = value;
            } else if (newAttributes.containsKey(XMLNS)) {
                defaultNamespaceUri = newAttributes.get(XMLNS).getValue();
            }

            String finalElementName = nameStr;
            if (!userAttributePrefix.equals(Constants.EMPTY_STRING)) {
                finalElementName = removeUserAttributePrefix(StringUtils.fromString(nameStr),
                        StringUtils.fromString(userAttributePrefix), null).getValue();
            }

            if (!defaultNamespaceUri.equals(Constants.EMPTY_STRING)) {
                element = CreateElement.createElement(
                        StringUtils.fromString("{" + defaultNamespaceUri + "}" + finalElementName),
                        newAttributes, children);
            } else {
                element = CreateElement.createElement(StringUtils.fromString(finalElementName),
                        newAttributes, children);
            }
        }
        return element;
    }


    public static BString removeUserAttributePrefix(BString name, BString userAttributePrefix, Object index) {
        String nameStr = name.getValue();
        String userAttributePrefixStr = userAttributePrefix.getValue();
        int usrAttIndex = nameStr.indexOf(userAttributePrefixStr);

        if (usrAttIndex != -1) {
            return StringUtils.fromString(nameStr.substring(usrAttIndex + 1, nameStr.length()));
        }

        if (index instanceof Long indexNum) {
            return StringUtils.fromString(nameStr.substring(indexNum.intValue() + 1, nameStr.length()));
        }
        return StringUtils.fromString(nameStr);
    }

    /**
     * Collects the XML attributes of a value: the parent's namespace declarations plus
     * the value's attribute-prefixed fields, with namespace-qualified keys resolved.
     *
     * @param jsonTree         the value whose attribute fields are read
     * @param options          the JSON-to-XML conversion options
     * @param namespaces       all namespace declarations seen so far, for prefix lookups
     * @param parentNamespaces namespace declarations inherited from the parent
     * @return the attribute map for the element being built
     */
    public static BMap<BString, BString> getAttributesMap(Object jsonTree,
                                                          BMap<BString, Object> options,
                                                          BMap<BString, BString> namespaces,
                                                          BMap<BString, BString> parentNamespaces) {
        BMap<BString, BString> attributes = (BMap<BString, BString>) parentNamespaces.copy(new HashMap<>());
        // Non-map values (scalars, arrays, nil) cannot carry attribute fields; the convert
        // below would throw for them and the catch would return this same copy.
        if (!(jsonTree instanceof BMap)) {
            return attributes;
        }
        try {
            BMap<BString, Object> attr = (BMap<BString, Object>) ValueUtils.convert(
                    jsonTree, Constants.JSON_MAP_TYPE);

            String attributePrefix = options.get(Constants.ATTRIBUTE_PREFIX).toString();
            for (Map.Entry<BString, Object> entry : attr.entrySet()) {
                String key = entry.getKey().toString();
                Object value = entry.getValue();
                if (!key.startsWith(attributePrefix)) {
                    continue;
                }

                if (value instanceof BMap || value instanceof BArray) {
                    DiagnosticLog.createXmlError("attribute cannot be an object or array.");
                }

                int index = key.indexOf(Constants.COLON);
                if (index != -1) {
                    String suffix = key.substring(index + 1);
                    if (key.startsWith(attributePrefix + XMLNS)) {
                        attributes.put(StringUtils.fromString(getXmlnsNameUrI() + suffix),
                                StringUtils.fromString(StringUtils.getStringValue(value)));
                    } else {
                        Long startIndex = getStartIndex(StringUtils.fromString(attributePrefix), StringUtils.fromString(
                                options.get(Constants.USER_ATTRIBUTE_PREFIX).toString()), StringUtils.fromString(key));
                        String prefix = key.substring(startIndex.intValue(), index);
                        BString namespaceUrl = namespaces.get(StringUtils.fromString(getXmlnsNameUrI() + prefix));
                        attributes.put(StringUtils.fromString("{" + namespaceUrl + "}" + suffix),
                                StringUtils.fromString(StringUtils.getStringValue(value)));
                    }
                } else {
                    if (key.equals(attributePrefix + XMLNS)) {
                        attributes.put(XMLNS, StringUtils.fromString(StringUtils.getStringValue(value)));
                    } else {
                        Long startIndex = getStartIndex(StringUtils.fromString(attributePrefix),
                                StringUtils.fromString(options.get(Constants.USER_ATTRIBUTE_PREFIX).toString()),
                                StringUtils.fromString(key));
                        attributes.put(StringUtils.fromString(key.substring(startIndex.intValue())),
                                StringUtils.fromString(StringUtils.getStringValue(value)));
                    }
                }
            }
            return attributes;
        } catch (BError e) {
            return attributes;
        }
    }

    public static Long getStartIndex(BString attributePrefix, BString userAttributePrefix, BString key) {
        String attributePrefixStr = attributePrefix.toString();
        String userAttributePrefixStr = userAttributePrefix.toString();
        String keyStr = key.toString();
        int startIndex = 1;

        if (!attributePrefixStr.equals(ATTRIBUTE_PREFIX.toString())) {
            return (long) startIndex;
        }

        int location = userAttributePrefixStr.equals(Constants.EMPTY_STRING) ? keyStr.indexOf("_")
                : keyStr.indexOf(userAttributePrefixStr);
        if (location != -1) {
            startIndex = location + 1;
        }
        return (long) startIndex;
    }

    /**
     * Collects the namespace declarations in scope for a value: the parent's declarations
     * plus any {@code xmlns} attribute fields the value itself carries.
     *
     * @param jsonTree         the value whose namespace attribute fields are read
     * @param options          the JSON-to-XML conversion options
     * @param parentNamespaces namespace declarations inherited from the parent
     * @return the namespace map in scope for the value
     */
    public static BMap<BString, BString> getNamespacesMap(Object jsonTree,
                                                           BMap<BString, Object> options,
                                                           BMap<BString, BString> parentNamespaces) {
        BMap<BString, BString> namespaces = (BMap<BString, BString>) parentNamespaces.copy(new HashMap<>());
        // Non-map values (scalars, arrays, nil) cannot carry namespace attribute fields; the
        // convert below would throw for them and the catch would return this same copy.
        if (!(jsonTree instanceof BMap)) {
            return namespaces;
        }
        try {
            Object jsonTreeObject = ValueUtils.convert(jsonTree, Constants.JSON_MAP_TYPE);
            BMap<BString, Object> attr = (BMap<BString, Object>) jsonTreeObject;
            String attributePrefix = options.get(Constants.ATTRIBUTE_PREFIX).toString();

            for (Map.Entry<BString, Object> entry : attr.entrySet()) {
                BString key = entry.getKey();
                Object value = entry.getValue();
                if (!key.getValue().startsWith(attributePrefix)) {
                    continue;
                }

                if (value instanceof BMap || value instanceof BArray) {
                    throw DiagnosticLog.createXmlError("attribute cannot be an object or array.");
                }

                if (!key.getValue().startsWith(attributePrefix + XMLNS)) {
                    continue;
                }

                int index = key.getValue().indexOf(Constants.COLON);
                if (index != -1) {
                    String prefix = key.getValue().substring(index + 1);
                    namespaces.put(StringUtils.fromString(getXmlnsNameUrI() + prefix),
                            StringUtils.fromString(StringUtils.getStringValue(value)));
                } else {
                    namespaces.put(StringUtils.fromString(getXmlnsNameUrI()),
                            StringUtils.fromString(StringUtils.getStringValue(value)));
                }
            }
            return namespaces;
        } catch (BError e) {
            return namespaces;
        }
    }

    private static String getXmlnsNameUrI() {
        return "{" + XMLNS_NAMESPACE_URI + "}";
    }

    public static void addNamespaces(BMap<BString, BString> allNamespaces, BMap<BString, BString> namespaces) {
        for (Map.Entry<BString, BString> entry: namespaces.entrySet()) {
            allNamespaces.put(entry.getKey(), entry.getValue());
        }
    }
}
