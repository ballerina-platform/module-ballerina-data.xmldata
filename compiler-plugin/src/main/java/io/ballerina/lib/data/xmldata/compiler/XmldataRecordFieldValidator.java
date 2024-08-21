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

package io.ballerina.lib.data.xmldata.compiler;

import io.ballerina.compiler.api.ModuleID;
import io.ballerina.compiler.api.SemanticModel;
import io.ballerina.compiler.api.symbols.AnnotationAttachmentSymbol;
import io.ballerina.compiler.api.symbols.AnnotationSymbol;
import io.ballerina.compiler.api.symbols.ArrayTypeSymbol;
import io.ballerina.compiler.api.symbols.ModuleSymbol;
import io.ballerina.compiler.api.symbols.RecordFieldSymbol;
import io.ballerina.compiler.api.symbols.RecordTypeSymbol;
import io.ballerina.compiler.api.symbols.Symbol;
import io.ballerina.compiler.api.symbols.SymbolKind;
import io.ballerina.compiler.api.symbols.TypeDefinitionSymbol;
import io.ballerina.compiler.api.symbols.TypeDescKind;
import io.ballerina.compiler.api.symbols.TypeReferenceTypeSymbol;
import io.ballerina.compiler.api.symbols.TypeSymbol;
import io.ballerina.compiler.api.symbols.UnionTypeSymbol;
import io.ballerina.compiler.api.symbols.VariableSymbol;
import io.ballerina.compiler.syntax.tree.CheckExpressionNode;
import io.ballerina.compiler.syntax.tree.ChildNodeList;
import io.ballerina.compiler.syntax.tree.ExpressionNode;
import io.ballerina.compiler.syntax.tree.FunctionCallExpressionNode;
import io.ballerina.compiler.syntax.tree.FunctionDefinitionNode;
import io.ballerina.compiler.syntax.tree.ImportDeclarationNode;
import io.ballerina.compiler.syntax.tree.ModuleMemberDeclarationNode;
import io.ballerina.compiler.syntax.tree.ModulePartNode;
import io.ballerina.compiler.syntax.tree.ModuleVariableDeclarationNode;
import io.ballerina.compiler.syntax.tree.NameReferenceNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.QualifiedNameReferenceNode;
import io.ballerina.compiler.syntax.tree.SyntaxKind;
import io.ballerina.compiler.syntax.tree.TypeDefinitionNode;
import io.ballerina.compiler.syntax.tree.VariableDeclarationNode;
import io.ballerina.lib.data.xmldata.compiler.objects.QualifiedName;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticFactory;
import io.ballerina.tools.diagnostics.DiagnosticInfo;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;
import io.ballerina.tools.diagnostics.Location;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Xmldata Record Field Validator.
 *
 * @since 0.1.0
 */
public class XmldataRecordFieldValidator implements AnalysisTask<SyntaxNodeAnalysisContext> {

    private SemanticModel semanticModel;
    private final HashMap<Location, DiagnosticInfo> allDiagnosticInfo = new HashMap<>();
    private String modulePrefix = Constants.XMLDATA;

    @Override
    public void perform(SyntaxNodeAnalysisContext ctx) {
        semanticModel = ctx.semanticModel();
        List<Diagnostic> diagnostics = semanticModel.diagnostics();
        boolean erroneousCompilation = diagnostics.stream()
                .anyMatch(d -> d.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR));
        if (erroneousCompilation) {
            reset();
            return;
        }

        ModulePartNode rootNode = (ModulePartNode) ctx.node();
        updateModulePrefix(rootNode);

        for (ModuleMemberDeclarationNode member : rootNode.members()) {
            switch (member.kind()) {
                case FUNCTION_DEFINITION -> processFunctionDefinitionNode((FunctionDefinitionNode) member, ctx);
                case MODULE_VAR_DECL ->
                        processModuleVariableDeclarationNode((ModuleVariableDeclarationNode) member, ctx);
                case TYPE_DEFINITION -> processTypeDefinitionNode((TypeDefinitionNode) member, ctx);
            }
        }

        reset();
    }

    private void reset() {
        semanticModel = null;
        allDiagnosticInfo.clear();
        modulePrefix = Constants.XMLDATA;
    }

    private void updateModulePrefix(ModulePartNode rootNode) {
        for (ImportDeclarationNode importDeclarationNode : rootNode.imports()) {
            Optional<Symbol> symbol = semanticModel.symbol(importDeclarationNode);
            if (symbol.isPresent() && symbol.get().kind() == SymbolKind.MODULE) {
                ModuleSymbol moduleSymbol = (ModuleSymbol) symbol.get();
                if (isXmldataImport(moduleSymbol)) {
                    modulePrefix = moduleSymbol.id().modulePrefix();
                    break;
                }
            }
        }
    }

    private boolean isXmldataImport(ModuleSymbol moduleSymbol) {
        ModuleID moduleId = moduleSymbol.id();
        return Constants.BALLERINA.equals(moduleId.orgName())
                && Constants.DATA_XMLDATA.equals(moduleId.moduleName());
    }

    private void processFunctionDefinitionNode(FunctionDefinitionNode functionDefinitionNode,
                                               SyntaxNodeAnalysisContext ctx) {
        ChildNodeList childNodeList = functionDefinitionNode.functionBody().children();
        for (Node node : childNodeList) {
            if (node.kind() != SyntaxKind.LOCAL_VAR_DECL) {
                continue;
            }
            VariableDeclarationNode variableDeclarationNode = (VariableDeclarationNode) node;
            Optional<ExpressionNode> initializer = variableDeclarationNode.initializer();
            if (initializer.isEmpty()) {
                continue;
            }
            Optional<Symbol> symbol = semanticModel.symbol(variableDeclarationNode.typedBindingPattern());
            if (symbol.isEmpty()) {
                continue;
            }

            TypeSymbol typeSymbol = ((VariableSymbol) symbol.get()).typeDescriptor();
            if (!isParseFunctionFromXmldata(initializer.get())) {
                validateAnnotationUsageInAllInlineExpectedTypes(typeSymbol, ctx);
                continue;
            }
            validateExpectedType(typeSymbol, symbol.get().getLocation(), ctx);
        }
    }

    private void validateAnnotationUsageInAllInlineExpectedTypes(TypeSymbol typeSymbol, SyntaxNodeAnalysisContext ctx) {
        switch (typeSymbol.typeKind()) {
            case RECORD -> validateRecordFieldNames((RecordTypeSymbol) typeSymbol, ctx);
            case UNION -> {
                for (TypeSymbol memberTSymbol : ((UnionTypeSymbol) typeSymbol).memberTypeDescriptors()) {
                    validateAnnotationUsageInAllInlineExpectedTypes(memberTSymbol, ctx);
                }
            }
        }
    }

    private void validateExpectedType(TypeSymbol typeSymbol, Optional<Location> location,
                                      SyntaxNodeAnalysisContext ctx) {
        if (isNotValidExpectedType(typeSymbol)) {
            reportDiagnosticInfo(ctx, location, XmldataDiagnosticCodes.EXPECTED_RECORD_TYPE);
        }

        switch (typeSymbol.typeKind()) {
            case RECORD -> {
                RecordTypeSymbol recordSymbol = (RecordTypeSymbol) typeSymbol;
                validateRecordFieldNames(recordSymbol, ctx);
                processRecordFieldsType(recordSymbol, ctx);
            }
            case TYPE_REFERENCE -> validateExpectedType(((TypeReferenceTypeSymbol) typeSymbol).typeDescriptor(),
                    location, ctx);
            case UNION -> {
                int recordCount = 0;
                for (TypeSymbol memberTSymbol : ((UnionTypeSymbol) typeSymbol).memberTypeDescriptors()) {
                    if (getReferredTypeSymbol(memberTSymbol).typeKind() == TypeDescKind.ERROR) {
                        continue;
                    }
                    if (getReferredTypeSymbol(memberTSymbol).typeKind() == TypeDescKind.RECORD) {
                        validateExpectedType(memberTSymbol, location, ctx);
                        recordCount++;
                    }
                }
                if (recordCount == 0) {
                    reportDiagnosticInfo(ctx, location, XmldataDiagnosticCodes.EXPECTED_RECORD_TYPE);
                }
            }
        }
    }

    private TypeSymbol getReferredTypeSymbol(TypeSymbol typeSymbol) {
        if (typeSymbol.typeKind() == TypeDescKind.TYPE_REFERENCE) {
            return ((TypeReferenceTypeSymbol) typeSymbol).typeDescriptor();
        }
        return typeSymbol;
    }

    private boolean isNotValidExpectedType(TypeSymbol typeSymbol) {
        switch (typeSymbol.typeKind()) {
            case RECORD -> {
                return false;
            }
            case TYPE_REFERENCE -> {
                return isNotValidExpectedType(((TypeReferenceTypeSymbol) typeSymbol).typeDescriptor());
            }
            case UNION -> {
                for (TypeSymbol memberTSymbol : ((UnionTypeSymbol) typeSymbol).memberTypeDescriptors()) {
                    if (getReferredTypeSymbol(memberTSymbol).typeKind() == TypeDescKind.ERROR) {
                        continue;
                    }

                    if (!(getReferredTypeSymbol(memberTSymbol).typeKind() == TypeDescKind.RECORD)) {
                        return true;
                    }
                }
                return false;
            }
        }
        return true;
    }

    private void processModuleVariableDeclarationNode(ModuleVariableDeclarationNode moduleVariableDeclarationNode,
                                                      SyntaxNodeAnalysisContext ctx) {
        Optional<ExpressionNode> initializer = moduleVariableDeclarationNode.initializer();
        if (initializer.isEmpty()) {
            return;
        }

        Optional<Symbol> symbol = semanticModel.symbol(moduleVariableDeclarationNode.typedBindingPattern());
        if (symbol.isEmpty()) {
            return;
        }
        TypeSymbol typeSymbol = ((VariableSymbol) symbol.get()).typeDescriptor();

        if (!isParseFunctionFromXmldata(initializer.get())) {
            validateAnnotationUsageInAllInlineExpectedTypes(typeSymbol, ctx);
            return;
        }
        validateExpectedType(typeSymbol, symbol.get().getLocation(), ctx);
    }

    private void processTypeDefinitionNode(TypeDefinitionNode typeDefinitionNode, SyntaxNodeAnalysisContext ctx) {
        Node typeDescriptor = typeDefinitionNode.typeDescriptor();
        if (typeDescriptor.kind() != SyntaxKind.RECORD_TYPE_DESC) {
            return;
        }
        validateRecordTypeDefinition(typeDefinitionNode, ctx);
    }

    private void validateRecordTypeDefinition(TypeDefinitionNode typeDefinitionNode, SyntaxNodeAnalysisContext ctx) {
        Optional<Symbol> symbol = semanticModel.symbol(typeDefinitionNode);
        if (symbol.isEmpty()) {
            return;
        }
        TypeDefinitionSymbol typeDefinitionSymbol = (TypeDefinitionSymbol) symbol.get();
        validateRecordFieldNames((RecordTypeSymbol) typeDefinitionSymbol.typeDescriptor(), ctx);
    }

    private void validateRecordFieldNames(RecordTypeSymbol recordTypeSymbol, SyntaxNodeAnalysisContext ctx) {
        List<QualifiedName> fieldMembers = new ArrayList<>();
        for (Map.Entry<String, RecordFieldSymbol> entry : recordTypeSymbol.fieldDescriptors().entrySet()) {
            RecordFieldSymbol fieldSymbol = entry.getValue();
            detectDuplicateFields(entry.getKey(), fieldSymbol, fieldMembers, ctx);
            if (fieldSymbol.typeDescriptor().typeKind() != TypeDescKind.TYPE_REFERENCE) {
                continue;
            }
            detectNameAnnotUsageWarning(fieldSymbol, ctx);
        }
    }

    private void detectDuplicateFields(String fieldName, RecordFieldSymbol fieldSymbol,
                                       List<QualifiedName> fieldMembers, SyntaxNodeAnalysisContext ctx) {
        QualifiedName fieldQName = getQNameFromAnnotation(fieldName, fieldSymbol.annotAttachments());
        if (fieldMembers.contains(fieldQName)) {
            reportDiagnosticInfo(ctx, fieldSymbol.getLocation(), XmldataDiagnosticCodes.DUPLICATE_FIELD);
            return;
        }
        fieldMembers.add(fieldQName);
    }

    private void detectNameAnnotUsageWarning(RecordFieldSymbol fieldSymbol, SyntaxNodeAnalysisContext ctx) {
        Optional<Location> location = fieldSymbol.typeDescriptor().getLocation();
        if (location.isEmpty()) {
            return;
        }

        TypeSymbol typeSymbol = fieldSymbol.typeDescriptor();
        if (typeSymbol.typeKind() != TypeDescKind.TYPE_REFERENCE) {
            return;
        }
        TypeReferenceTypeSymbol typeReferenceTypeSymbol = (TypeReferenceTypeSymbol) typeSymbol;
        Symbol symbol = typeReferenceTypeSymbol.definition();
        if (symbol == null || symbol.kind() != SymbolKind.TYPE_DEFINITION) {
            return;
        }
        TypeDefinitionSymbol typeDefinitionSymbol = (TypeDefinitionSymbol) symbol;
        typeDefinitionSymbol.annotations().forEach(annotationSymbol -> {
            if (!isAnnotFromXmldata(annotationSymbol)) {
                return;
            }
            Optional<String> annotName = annotationSymbol.getName();
            if (annotName.isPresent() && annotName.get().equals(Constants.NAME)) {
                reportDiagnosticInfo(ctx, typeDefinitionSymbol.getLocation(),
                        XmldataDiagnosticCodes.NAME_ANNOTATION_NOT_ALLOWED);
            }
        });
    }

    private void processRecordFieldsType(RecordTypeSymbol recordTypeSymbol, SyntaxNodeAnalysisContext ctx) {
        for (Map.Entry<String, RecordFieldSymbol> entry : recordTypeSymbol.fieldDescriptors().entrySet()) {
            RecordFieldSymbol fieldSymbol = entry.getValue();
            TypeSymbol typeSymbol = fieldSymbol.typeDescriptor();
            validateRecordFieldType(typeSymbol, fieldSymbol.getLocation(), ctx);
        }
    }

    private void validateRecordFieldType(TypeSymbol typeSymbol, Optional<Location> location,
                                         SyntaxNodeAnalysisContext ctx) {
        switch (typeSymbol.typeKind()) {
//            case UNION -> validateUnionType((UnionTypeSymbol) typeSymbol, location, ctx);
            case NIL, TUPLE -> reportDiagnosticInfo(ctx, location, XmldataDiagnosticCodes.UNSUPPORTED_TYPE);
            case ARRAY -> validateRecordFieldType(((ArrayTypeSymbol) typeSymbol).memberTypeDescriptor(), location, ctx);
            case TYPE_REFERENCE ->
                    validateRecordFieldType(((TypeReferenceTypeSymbol) typeSymbol).typeDescriptor(), location, ctx);
        }
    }

//    private void validateUnionType(UnionTypeSymbol unionTypeSymbol, Optional<Location> location,
//                                   SyntaxNodeAnalysisContext ctx) {
//        int nonPrimitiveMemberCount = 0;
//        boolean isNilPresent = false;
//        List<TypeSymbol> memberTypeSymbols = unionTypeSymbol.memberTypeDescriptors();
//        for (TypeSymbol memberTypeSymbol : memberTypeSymbols) {
//            if (isPrimitiveType(memberTypeSymbol)) {
//                continue;
//            }
//
//            if (memberTypeSymbol.typeKind() == TypeDescKind.NIL) {
//                isNilPresent = true;
//            }
//            nonPrimitiveMemberCount++;
//        }
//
//        if (nonPrimitiveMemberCount > 1 || (memberTypeSymbols.size() > 1 && isNilPresent)) {
//            reportDiagnosticInfo(ctx, location, XmldataDiagnosticCodes.UNSUPPORTED_UNION_TYPE);
//        }
//    }

    private boolean isPrimitiveType(TypeSymbol typeSymbol) {
        TypeDescKind kind = typeSymbol.typeKind();
        if (kind == TypeDescKind.TYPE_REFERENCE) {
            kind = ((TypeReferenceTypeSymbol) typeSymbol).typeDescriptor().typeKind();
        }

        return kind == TypeDescKind.INT || kind == TypeDescKind.FLOAT || kind == TypeDescKind.DECIMAL
                || kind == TypeDescKind.STRING || kind == TypeDescKind.BOOLEAN || kind == TypeDescKind.BYTE;
    }

    private boolean isAnnotFromXmldata(AnnotationSymbol annotationSymbol) {
        Optional<ModuleSymbol> moduleSymbol = annotationSymbol.getModule();
        if (moduleSymbol.isEmpty()) {
            return false;
        }
        Optional<String> moduleName = moduleSymbol.get().getName();
        return moduleName.map(val -> val.contains(Constants.XMLDATA)).orElse(false);
    }

    private QualifiedName getQNameFromAnnotation(String fieldName,
                                                 List<AnnotationAttachmentSymbol> annotationAttachments) {
        String uri = "";
        String name = fieldName;
        String prefix = "";
        boolean isAttribute = false;
        for (AnnotationAttachmentSymbol annotAttSymbol : annotationAttachments) {
            AnnotationSymbol annotation = annotAttSymbol.typeDescriptor();
            if (!getAnnotModuleName(annotation).contains(Constants.XMLDATA)) {
                continue;
            }
            Optional<String> nameAnnot = annotation.getName();
            if (nameAnnot.isEmpty()) {
                continue;
            }
            String value = nameAnnot.get();
            if (value.equals(Constants.NAME)) {
                name = ((LinkedHashMap<?, ?>) annotAttSymbol.attachmentValue().orElseThrow().value())
                        .get("value").toString();
            } else if (value.equals(Constants.NAMESPACE)) {
                Object temp = ((LinkedHashMap<String, Object>) annotAttSymbol.attachmentValue().orElseThrow().value())
                            .get("prefix");
                if (temp != null) {
                    prefix = temp.toString();
                }
                uri = ((LinkedHashMap<?, ?>) annotAttSymbol.attachmentValue().orElseThrow().value())
                        .get("uri").toString();
            } else if (value.equals(Constants.ATTRIBUTE)) {
                isAttribute = true;
            }
        }
        return new QualifiedName(uri, name, prefix, isAttribute);
    }

    private String getAnnotModuleName(AnnotationSymbol annotation) {
        Optional<ModuleSymbol> moduleSymbol = annotation.getModule();
        if (moduleSymbol.isEmpty()) {
            return "";
        }
        Optional<String> moduleName = moduleSymbol.get().getName();
        return moduleName.orElse("");
    }

    private boolean isParseFunctionFromXmldata(ExpressionNode expressionNode) {
        if (expressionNode.kind() == SyntaxKind.CHECK_EXPRESSION) {
            expressionNode = ((CheckExpressionNode) expressionNode).expression();
        }

        if (expressionNode.kind() != SyntaxKind.FUNCTION_CALL) {
            return false;
        }

        NameReferenceNode nameReferenceNode = ((FunctionCallExpressionNode) expressionNode).functionName();
        if (nameReferenceNode.kind() != SyntaxKind.QUALIFIED_NAME_REFERENCE) {
            return false;
        }
        String prefix = ((QualifiedNameReferenceNode) nameReferenceNode).modulePrefix().text();
        if (!prefix.equals(modulePrefix)) {
            return false;
        }

        String functionName = ((FunctionCallExpressionNode) expressionNode).functionName().toSourceCode().trim();
        return functionName.contains(Constants.PARSE_STRING) || functionName.contains(Constants.PARSE_BYTES)
                || functionName.contains(Constants.PARSE_STREAM) || functionName.contains(Constants.PARSE_AS_TYPE);
    }

    private void reportDiagnosticInfo(SyntaxNodeAnalysisContext ctx, Optional<Location> location,
                                      XmldataDiagnosticCodes diagnosticsCodes) {
        if (location.isEmpty()) {
            return;
        }
        Location pos = location.get();
        DiagnosticInfo diagnosticInfo = new DiagnosticInfo(diagnosticsCodes.getCode(),
                diagnosticsCodes.getMessage(), diagnosticsCodes.getSeverity());
        if (allDiagnosticInfo.containsKey(pos) && allDiagnosticInfo.get(pos).equals(diagnosticInfo)) {
            return;
        }
        allDiagnosticInfo.put(pos, diagnosticInfo);
        ctx.reportDiagnostic(DiagnosticFactory.createDiagnostic(diagnosticInfo, pos));
    }
}
