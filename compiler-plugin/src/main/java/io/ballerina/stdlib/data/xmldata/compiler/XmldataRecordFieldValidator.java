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

package io.ballerina.stdlib.data.xmldata.compiler;

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
import io.ballerina.compiler.syntax.tree.ModuleMemberDeclarationNode;
import io.ballerina.compiler.syntax.tree.ModulePartNode;
import io.ballerina.compiler.syntax.tree.ModuleVariableDeclarationNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.SyntaxKind;
import io.ballerina.compiler.syntax.tree.TypeDefinitionNode;
import io.ballerina.compiler.syntax.tree.VariableDeclarationNode;
import io.ballerina.projects.Document;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.stdlib.data.xmldata.compiler.objects.QualifiedName;
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
    private Document srcFile;
    private final HashMap<Location, DiagnosticInfo> allDiagnosticInfo = new HashMap<>();

    @Override
    public void perform(SyntaxNodeAnalysisContext ctx) {
        semanticModel = ctx.semanticModel();
        srcFile = ctx.currentPackage().getDefaultModule().document(ctx.documentId());
        List<Diagnostic> diagnostics = semanticModel.diagnostics();
        boolean erroneousCompilation = diagnostics.stream()
                .anyMatch(d -> d.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR));
        if (erroneousCompilation) {
            return;
        }

        ModulePartNode rootNode = (ModulePartNode) ctx.node();
        for (ModuleMemberDeclarationNode member : rootNode.members()) {
            switch (member.kind()) {
                case FUNCTION_DEFINITION -> processFunctionDefinitionNode((FunctionDefinitionNode) member, ctx);
                case MODULE_VAR_DECL ->
                        processModuleVariableDeclarationNode((ModuleVariableDeclarationNode) member, ctx);
                case TYPE_DEFINITION -> processTypeDefinitionNode((TypeDefinitionNode) member, ctx);
            }
        }
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
            if (!isFromXmlFunctionFromXmldata(initializer.get())) {
                if (typeSymbol.typeKind() == TypeDescKind.RECORD) {
                    validateRecordFields((RecordTypeSymbol) typeSymbol, ctx);
                }
                continue;
            }

            if (typeSymbol.typeKind() == TypeDescKind.TYPE_REFERENCE) {
                typeSymbol = ((TypeReferenceTypeSymbol) typeSymbol).typeDescriptor();
                if (typeSymbol.typeKind() != TypeDescKind.RECORD) {
                    reportDiagnosticInfo(ctx, symbol.get().getLocation(), XmldataDiagnosticCodes.EXPECTED_RECORD_TYPE);
                    continue;
                }
                processRecordFieldsType((RecordTypeSymbol) typeSymbol, ctx);
            } else if (typeSymbol.typeKind() != TypeDescKind.RECORD) {
                reportDiagnosticInfo(ctx, symbol.get().getLocation(), XmldataDiagnosticCodes.EXPECTED_RECORD_TYPE);
                continue;
            }
            RecordTypeSymbol recordSymbol = (RecordTypeSymbol) typeSymbol;
            validateRecordFields(recordSymbol, ctx);
            processRecordFieldsType(recordSymbol, ctx);
        }
    }

    private void processModuleVariableDeclarationNode(ModuleVariableDeclarationNode moduleVariableDeclarationNode,
                                                      SyntaxNodeAnalysisContext ctx) {
        Optional<ExpressionNode> initializer = moduleVariableDeclarationNode.initializer();
        if (initializer.isEmpty() || !isFromXmlFunctionFromXmldata(initializer.get())) {
            return;
        }

        Optional<Symbol> symbol = semanticModel.symbol(moduleVariableDeclarationNode.typedBindingPattern());
        if (symbol.isEmpty()) {
            return;
        }
        TypeSymbol typeSymbol = ((VariableSymbol) symbol.get()).typeDescriptor();
        if (typeSymbol.typeKind() == TypeDescKind.TYPE_REFERENCE) {
            typeSymbol = ((TypeReferenceTypeSymbol) typeSymbol).typeDescriptor();
            if (typeSymbol.typeKind() != TypeDescKind.RECORD) {
                reportDiagnosticInfo(ctx, symbol.get().getLocation(),
                        XmldataDiagnosticCodes.EXPECTED_RECORD_TYPE);
                return;
            }
            processRecordFieldsType((RecordTypeSymbol) typeSymbol, ctx);
        } else if (typeSymbol.typeKind() != TypeDescKind.RECORD) {
            reportDiagnosticInfo(ctx, symbol.get().getLocation(), XmldataDiagnosticCodes.EXPECTED_RECORD_TYPE);
            return;
        }
        validateRecordFields((RecordTypeSymbol) typeSymbol, ctx);
        processRecordFieldsType((RecordTypeSymbol) typeSymbol, ctx);
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
        validateRecordFields((RecordTypeSymbol) typeDefinitionSymbol.typeDescriptor(), ctx);
    }

    private void validateRecordFields(RecordTypeSymbol recordTypeSymbol, SyntaxNodeAnalysisContext ctx) {
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

        Optional<Symbol> symbol = semanticModel.symbol(srcFile, location.get().lineRange().startLine());
        if (symbol.isEmpty()) {
            return;
        }

        if (symbol.get().kind() != SymbolKind.TYPE_DEFINITION) {
            return;
        }
        TypeDefinitionSymbol typeDefinitionSymbol = (TypeDefinitionSymbol) symbol.get();
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
            case UNION -> validateUnionType((UnionTypeSymbol) typeSymbol, location, ctx);
            case NIL, TUPLE -> reportDiagnosticInfo(ctx, location, XmldataDiagnosticCodes.UNSUPPORTED_TYPE);
            case ARRAY -> validateRecordFieldType(((ArrayTypeSymbol) typeSymbol).memberTypeDescriptor(), location, ctx);
            case TYPE_REFERENCE ->
                    validateRecordFieldType(((TypeReferenceTypeSymbol) typeSymbol).typeDescriptor(), location, ctx);
        }
    }

    private void validateUnionType(UnionTypeSymbol unionTypeSymbol, Optional<Location> location,
                                   SyntaxNodeAnalysisContext ctx) {
        int nonPrimitiveMemberCount = 0;
        boolean isNilPresent = false;
        List<TypeSymbol> memberTypeSymbols = unionTypeSymbol.memberTypeDescriptors();
        for (TypeSymbol memberTypeSymbol : memberTypeSymbols) {
            if (isPrimitiveType(memberTypeSymbol)) {
                continue;
            }

            if (memberTypeSymbol.typeKind() == TypeDescKind.NIL) {
                isNilPresent = true;
            }
            nonPrimitiveMemberCount++;
        }

        if (nonPrimitiveMemberCount > 1 || (memberTypeSymbols.size() > 1 && isNilPresent)) {
            reportDiagnosticInfo(ctx, location, XmldataDiagnosticCodes.UNSUPPORTED_UNION_TYPE);
        }
    }

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
        for (AnnotationAttachmentSymbol annotAttSymbol : annotationAttachments) {
            Optional<String> nameAnnot = annotAttSymbol.typeDescriptor().getName();
            if (nameAnnot.isEmpty()) {
                continue;
            }
            String value = nameAnnot.get();
            if (value.equals(Constants.NAME)) {
                name = ((LinkedHashMap<?, ?>) annotAttSymbol.attachmentValue().orElseThrow().value())
                        .get("value").toString();
            } else if (value.equals(Constants.NAMESPACE)) {
                prefix = ((LinkedHashMap<?, ?>) annotAttSymbol.attachmentValue().orElseThrow().value())
                            .get("prefix").toString();
                uri = ((LinkedHashMap<?, ?>) annotAttSymbol.attachmentValue().orElseThrow().value())
                        .get("uri").toString();
            }
        }
        return new QualifiedName(uri, name, prefix);
    }

    private boolean isFromXmlFunctionFromXmldata(ExpressionNode expressionNode) {
        if (expressionNode.kind() == SyntaxKind.CHECK_EXPRESSION) {
            expressionNode = ((CheckExpressionNode) expressionNode).expression();
        }

        if (expressionNode.kind() != SyntaxKind.FUNCTION_CALL) {
            return false;
        }
        String functionName = ((FunctionCallExpressionNode) expressionNode).functionName().toSourceCode().trim();
        return functionName.contains(Constants.FROM_XML_STRING_WITH_TYPE)
                || functionName.contains(Constants.FROM_XML_WITH_TYPE);
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
