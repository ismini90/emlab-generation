/*******************************************************************************
 * Copyright 2013 the original author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/
package emlab.gen.trend;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Reads Key Value pairs from a csv file. Keys should be in coulmn 1 and their
 * corresponding values in column 2. Can be used as an alternative method to
 * initializing hash maps on xml beans
 * 
 * @author Kaveri3012
 *
 */
public class KeyValuePairCSVReader {

    Logger logger = LoggerFactory.getLogger(KeyValuePairCSVReader.class);

    private String filename;

    private String delimiter;

    private String variableName;

    public String getFilename() {
        return filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }

    public String getDelimiter() {
        return delimiter;
    }

    public void setDelimiter(String delimiter) {
        this.delimiter = delimiter;
    }

    public String getVariableName() {
        return variableName;
    }

    public void setVariableName(String variableName) {
        this.variableName = variableName;
    }

}
