package com.cloudwebrtc.webrtc.utils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class ConstraintsMap {

    private final Map<String, Object> mMap;

    public ConstraintsMap(){
        mMap = new HashMap();
    }

    public ConstraintsMap(Map<String, Object> map){
        this.mMap = map;
    }

    public Map<String, Object> toMap() {
        return mMap;
    }

    public boolean hasKey(String name){
        return mMap.containsKey(name);
    }

    public boolean getBoolean(String name){
        return (boolean) mMap.get(name);
    }

    public double getDouble(String name){
        return (double) mMap.get(name);
    }

    public int getInt(String name) {
        if(getType(name) == ObjectType.String) {
            return Integer.parseInt(((String)mMap.get(name)));
        }
        return (int) mMap.get(name);
    }

    @Nullable
    public String getString(String name){
        return (String) mMap.get(name);
    }

    @Nullable
    public ConstraintsMap getMap(String name){
        Object value = mMap.get(name);
        if (value == null) {
            return null;
        }
        return new ConstraintsMap((Map<String, Object>) value);
    }

    @NonNull
    public ObjectType getType(String name) {
        Object value = mMap.get(name);

        if (value instanceof Number) {
            return ObjectType.Number;
        } else if (value instanceof String) {
            return ObjectType.String;
        } else if (value instanceof Boolean) {
            return ObjectType.Boolean;
        } else if (value instanceof Map) {
            return ObjectType.Map;
        } else if (value instanceof ArrayList) {
            return ObjectType.Array;
        } else {
            throw new IllegalArgumentException(
                    String.format(
                            "Invalid value %s for key %s contained in ConstraintsMap",
                            value, name));
        }
    }

    public void putBoolean(String key, boolean value) {
        mMap.put(key, value);
    }

    public void putDouble(String key, double value) {
        mMap.put(key, value);
    }

    public void putInt(String key, int value) {
        mMap.put(key, value);
    }

    public void putLong(String key, long value) {
        mMap.put(key, value);
    }

    public void putString(String key, String value) {
        mMap.put(key, value);
    }

    public void putMap(String key, Map<String, Object> value) {
        mMap.put(key, value);
    }

    public void putArray(String key, ArrayList<Object> value) {
        mMap.put(key, value);
    }

    @Nullable
    public ConstraintsArray getArray(String name){
        Object value = mMap.get(name);
        if (value == null) {
            return null;
        }
        return new ConstraintsArray((ArrayList<Object>) value);
    }
}
