/*

Taken from: https://github.com/aartikov/Sesame/tree/master/sesame-property/src/main/kotlin/me/aartikov/sesame/property

The MIT License (MIT)

Copyright (c) 2021 Artur Artikov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 */

package com.cloudwebrtc.webrtc.utils

import com.cloudwebrtc.webrtc.utils.DelegateAccess.delegate
import com.cloudwebrtc.webrtc.utils.DelegateAccess.delegateRequested
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlin.reflect.KProperty
import kotlin.reflect.KProperty0

/**
 * A little circuitous but the way this works is:
 * 1. [delegateRequested] set to true indicates that [delegate] should be filled.
 * 2. Upon [getValue], [delegate] is set.
 * 3. [KProperty0.delegate] returns the value previously set to [delegate]
 */
internal object DelegateAccess {
    internal val delegate = ThreadLocal<Any?>()
    internal val delegateRequested = ThreadLocal<Boolean>().apply { set(false) }
}

internal val <T> KProperty0<T>.delegate: Any?
    get() {
        try {
            delegateRequested.set(true)
            this.get()
            return DelegateAccess.delegate.get()
        } finally {
            DelegateAccess.delegate.set(null)
            delegateRequested.set(false)
        }
    }

/**
 * @return the flow associated with a [FlowObservable] property,
 * which can be collected upon to observe changes in the value.
 */
@Suppress("UNCHECKED_CAST")
val <T> KProperty0<T>.flow: StateFlow<T>
    get() = delegate as StateFlow<T>

/**
 * Indicates that the target property changes can be observed with [flow].
 */
@Target(AnnotationTarget.CLASS, AnnotationTarget.PROPERTY, AnnotationTarget.PROPERTY_GETTER)
@Retention(AnnotationRetention.BINARY)
@MustBeDocumented
annotation class FlowObservable

/**
 * @suppress
 */
@FlowObservable
class MutableStateFlowDelegate<T>
internal constructor(
    private val flow: MutableStateFlow<T>,
    private val onSetValue: ((newValue: T, oldValue: T) -> Unit)? = null,
) : MutableStateFlow<T> by flow {

    operator fun getValue(thisRef: Any?, property: KProperty<*>): T {
        if (delegateRequested.get() == true) {
            delegate.set(this)
        }
        return flow.value
    }

    operator fun setValue(thisRef: Any?, property: KProperty<*>, value: T) {
        val oldValue = flow.value
        flow.value = value
        onSetValue?.invoke(value, oldValue)
    }
}

/**
 * @suppress
 */
@FlowObservable
class StateFlowDelegate<T>
internal constructor(
    private val flow: StateFlow<T>,
) : StateFlow<T> by flow {

    operator fun getValue(thisRef: Any?, property: KProperty<*>): T {
        if (delegateRequested.get() == true) {
            delegate.set(this)
        }
        return flow.value
    }
}

/**
 * @suppress
 */
fun <T> flowDelegate(
    initialValue: T,
    onSetValue: ((newValue: T, oldValue: T) -> Unit)? = null,
): MutableStateFlowDelegate<T> {
    return MutableStateFlowDelegate(MutableStateFlow(initialValue), onSetValue)
}

/**
 * @suppress
 */
fun <T> flowDelegate(
    stateFlow: StateFlow<T>,
): StateFlowDelegate<T> {
    return StateFlowDelegate(stateFlow)
}

