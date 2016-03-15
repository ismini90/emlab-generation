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
package emlab.gen.role.tender;

/**
 * @author kaveri
 *
 */

import static org.junit.Assert.assertEquals;

import org.junit.Before;
import org.junit.Test;

import emlab.gen.domain.policy.renewablesupport.RenewableSupportSchemeTender;

public class Tester {

    RenewableSupportSchemeTender tester = new RenewableSupportSchemeTender();

    @Before
    public void Setup() {

        tester.setFutureTenderOperationStartTime(0);

    }

    @Test
    public void multiplicationOfZeroIntegersShouldReturnZero() {

        // MyClass is tested

        System.out.println("hello");

        // assert statements
        assertEquals("10 x 0 must be 0", 1, tester.getFutureTenderOperationStartTime());

    }

}
