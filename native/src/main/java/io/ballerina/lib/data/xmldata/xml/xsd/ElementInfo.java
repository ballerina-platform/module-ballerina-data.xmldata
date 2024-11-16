package io.ballerina.lib.data.xmldata.xml.xsd;

import io.ballerina.lib.data.xmldata.utils.Constants;
import io.ballerina.lib.data.xmldata.utils.DiagnosticErrorCode;
import io.ballerina.lib.data.xmldata.utils.DiagnosticLog;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

public class ElementInfo {
    String name;
    String fieldName;
    public long minOccurs;
    public long maxOccurs;
    public int occurrences;

    public boolean isInsideChoice = false;

    public ElementInfo(String name, String fieldName, BMap<BString, Object> element) {
        this.name = name;
        this.fieldName = fieldName;
        if (element.containsKey(Constants.MIN_OCCURS)) {
            this.minOccurs = element.getIntValue(Constants.MIN_OCCURS);
        } else {
            this.minOccurs = 1;
        }

        if (element.containsKey(Constants.MAX_OCCURS)) {
            this.maxOccurs = element.getIntValue(Constants.MAX_OCCURS);
        } else {
            this.maxOccurs = Math.max(this.minOccurs, 1);
        }
        this.occurrences = 0;
    }

    public void updateOccurrences() {
        this.occurrences++;
        if (this.occurrences > this.maxOccurs) {
            throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_MORE_THAN_MAX_ALLOWED_TIMES, name);
        }
    }

    public void validate() {
        validateMinOccurrences();
    }

    private void validateMinOccurrences() {
        if (!isInsideChoice && this.occurrences < this.minOccurs) {
            throw DiagnosticLog.error(DiagnosticErrorCode.ELEMENT_OCCURS_LESS_THAN_MIN_REQUIRED_TIMES, name);
        }
    }
}
