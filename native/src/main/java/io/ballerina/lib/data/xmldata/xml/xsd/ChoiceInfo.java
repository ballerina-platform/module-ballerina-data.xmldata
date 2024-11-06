package io.ballerina.lib.data.xmldata.xml.xsd;

import io.ballerina.lib.data.xmldata.utils.Constants;
import io.ballerina.lib.data.xmldata.xml.QualifiedName;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.Map;

public class ChoiceInfo implements ModelGroupInfo {
    public String fieldName;
    public long minOccurs;
    public long maxOccurs;
    public int occurrences = 0;

    // TODO: Update to a hashset<String>
    public Map<QualifiedName, Field> elements;


    public ChoiceInfo(String fieldName, BMap<BString, Object> element, Type fieldType) {
        this.fieldName = fieldName;
        if (element.containsKey(Constants.MIN_OCCURS)) {
            this.minOccurs = element.getIntValue(Constants.MIN_OCCURS);
        } else {
            this.minOccurs = 1;
        }

        if (element.containsKey(Constants.MAX_OCCURS)) {
            this.minOccurs = element.getIntValue(Constants.MAX_OCCURS);
        } else {
            this.maxOccurs = Math.max(this.minOccurs, 1);
        }
        this.occurrences = 1;
    }

    public void updateOccurrences() {
        this.occurrences++;
        if (this.occurrences > this.maxOccurs) {
            throw new RuntimeException(fieldName + " Element occurs more than the max allowed times");
        }
    }

    public void validateMinOccurrences() {
        if (this.occurrences < this.minOccurs) {
            throw new RuntimeException(fieldName + " Element occurs less than the min required times");
        }
    }

    @Override
    public void validate() {

    }

    @Override
    public void reset() {

    }

    @Override
    public void visit(String element) {

    }

    @Override
    public boolean isCompleted() {
        return false;
    }

    @Override
    public boolean isElementContains(String elementName) {
        return false;
    }
}
