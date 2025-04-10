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

import io.ballerina.projects.DiagnosticResult;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;
import org.testng.Assert;
import org.testng.annotations.Test;

import java.util.List;
import java.util.stream.Collectors;

import static io.ballerina.lib.data.xmldata.compiler.CompilerPluginTestUtils.getErrorMessage;

/**
 * This class includes tests for Ballerina Xmldata compiler plugin.
 */
public class CompilerPluginTest {
    @Test
    public void testDuplicateFieldNegative1() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_1").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 1);
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 0),
                "invalid field: duplicate field found");
    }

    @Test
    public void testDuplicateFieldNegative2() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_2").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 1);
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 0),
                "invalid field: duplicate field found");
    }

    @Test
    public void testChildRecordWithNameAnnotNegative() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_6").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.WARNING))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 1);
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 0),
                "invalid annotation attachment: child record does not allow name annotation");
    }

    @Test
    public void testDuplicateFieldInInlineRecordsNegative() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_8").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 4);
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 0),
                "invalid field: duplicate field found");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 1),
                "invalid field: duplicate field found");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 2),
                "invalid field: duplicate field found");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 3),
                "invalid field: duplicate field found");
    }

    @Test
    public void testUnionTypeNegative() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_9").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 6);
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 0),
                "invalid type: expected a record type");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 1),
                "invalid field: duplicate field found");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 2),
                "invalid field: duplicate field found");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 3),
                "invalid type: expected a record type");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 4),
                "invalid field: duplicate field found");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 5),
                "invalid field: duplicate field found");
    }

    @Test
    public void testCompilerPluginWithAProjectWithSubModule() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_10").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 1);
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 0),
                "invalid field: duplicate field found");

        List<Diagnostic> warningDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.WARNING))
                .collect(Collectors.toList());
        Assert.assertEquals(warningDiagnosticsList.size(), 1);
        Assert.assertEquals(warningDiagnosticsList.get(0).diagnosticInfo().messageFormat(),
                "invalid annotation attachment: child record does not allow name annotation");
    }

    @Test
    public void testCompilerPluginWithXsdAnnotation() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_11").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 24);
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 0),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 1),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 2),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 3),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 4),
                "Invalid sequence member: Sequence members should be defined in a closed record");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 5),
                "Invalid sequence member: Sequence members should be defined in a closed record");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 6),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 7),
                "Invalid sequence member: Sequence members should be defined in a closed record");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 8),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 9),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 10),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 11),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 12),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 13),
                "Invalid choice member: Choice members should be defined in a closed record");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 14),
                "Invalid choice member: Choice members should be defined in a closed record");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 15),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 16),
                "Invalid choice member: Choice members should be defined in a closed record");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 17),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 18),
                "A record field cannot contains sequence/choice/element/attribute annotations simultaneously");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 19),
                "A record field cannot contains sequence/choice/element/attribute annotations simultaneously");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 20),
                "A record field cannot contains sequence/choice/element/attribute annotations simultaneously");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 21),
                "A record field cannot contains sequence/choice/element/attribute annotations simultaneously");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 22),
                "Invalid choice member: Choice members should be defined in a closed record");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 23),
                "A record field cannot contains sequence/choice/element/attribute annotations simultaneously");
    }

    @Test
    public void testCompilerPluginWithXsdAnnotation2() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_12").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 6);
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 0),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 1),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 2),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 3),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 4),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 5),
                "invalid xsd annotation: record type or record array type expected");
    }

    @Test
    public void testCompilerPluginWithXsdAnnotation3() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_13").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 9);
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 0),
                "Invalid sequence member: Order should be defined in in all fields");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 1),
                "Invalid sequence member: Sequence members should be defined in a closed record");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 2),
                "Invalid sequence member: Order should be defined in in all fields");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 3),
                "Invalid sequence member: Sequence members should be defined in a closed record");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 4),
                "Invalid sequence member: Order should be defined in in all fields");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 5),
                "Invalid sequence member: Order should be defined in in all fields");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 6),
                "Invalid choice member: Choice members should be defined in a closed record");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 7),
                "invalid xsd annotation: record type or record array type expected");
        Assert.assertEquals(getErrorMessage(errorDiagnosticsList, 8),
                "Invalid choice member: Choice members should be defined in a closed record");
    }

    @Test
    public void testXPathDiagnostics() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_14").getCompilation().diagnosticResult();
        List<Diagnostic> expectedTypeErrors = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .filter(diagnostic -> diagnostic.diagnosticInfo().messageFormat()
                        .equals(XmldataDiagnosticCodes.UNSUPPORTED_XPATH_TYPE.getMessage())).toList();
        Assert.assertEquals(expectedTypeErrors.size(), 4);
    }

}
