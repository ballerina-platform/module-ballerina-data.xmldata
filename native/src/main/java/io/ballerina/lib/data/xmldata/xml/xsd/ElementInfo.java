package io.ballerina.lib.data.xmldata.xml.xsd;

import io.ballerina.lib.data.xmldata.utils.Constants;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

public class ElementInfo {
    String name;
    public long minOccurs;
    public long maxOccurs;
    public int occurrences = 0;

    public ElementInfo(String name, BMap<BString, Object> element) {
        this.name = name;
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
            throw new RuntimeException(name + " Element occurs more than the max allowed times");
        }
    }

    public void validateMinOccurrences() {
        if (this.occurrences < this.minOccurs) {
            throw new RuntimeException(name + " Element occurs less than the min required times");
        }
    }
}
