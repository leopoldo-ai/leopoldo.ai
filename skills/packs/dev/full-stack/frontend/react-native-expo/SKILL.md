---
name: react-native-expo
description: "Use when building mobile apps with React Native and Expo. Covers project setup, Expo Router navigation, NativeWind styling, EAS Build/Submit, and cross-platform patterns. OSS-first: Expo (OSS) primary, bare React Native CLI as advanced fallback. Triggers on: React Native, Expo, mobile app, Expo Router, EAS, NativeWind, mobile development, iOS, Android."
type: technique
metadata:
  author: leopoldo
  source: https://github.com/expo/skills
  created: 2026-03-24
  forge_strategy: adapt
  forge_sources:
    - https://github.com/expo/skills
    - https://github.com/callstackincubator/agent-skills
license: MIT
upstream:
  url: https://github.com/expo/skills
  version: main
  last_checked: 2026-03-24
---

# React Native Expo -- Mobile App Development

## Why This Exists

| Problem | Solution |
|---------|----------|
| Zero mobile coverage in plugin, mobile is 50% of dev market | Complete Expo patterns for iOS + Android |
| React Native setup is complex without Expo | Expo makes it zero-config with managed workflow |
| Web developers struggle transitioning to mobile | Patterns that leverage existing React/Next.js knowledge |

Adapted from official [expo/skills](https://github.com/expo/skills) and [callstackincubator/agent-skills](https://github.com/callstackincubator/agent-skills).

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Alternative) |
|-------------------|----------------------|
| Expo (managed workflow) | Bare React Native CLI |
| Expo Router (file-based nav) | React Navigation (manual) |
| NativeWind (Tailwind for RN) | StyleSheet, Tamagui |
| EAS Build/Submit | Local Xcode/Gradle |

## Core Workflow

### 1. Project Setup

```bash
npx create-expo-app@latest my-app --template tabs
cd my-app
npx expo start
```

Key files:
- `app/` -- File-based routing (Expo Router)
- `app/(tabs)/` -- Tab navigation group
- `app/_layout.tsx` -- Root layout
- `app.json` -- Expo config (name, icon, splash, plugins)

### 2. Expo Router Navigation

```typescript
// app/_layout.tsx - Root layout with stack
import { Stack } from "expo-router"

export default function RootLayout() {
  return (
    <Stack>
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      <Stack.Screen name="modal" options={{ presentation: "modal" }} />
    </Stack>
  )
}

// app/(tabs)/_layout.tsx - Tab navigation
import { Tabs } from "expo-router"
import { Ionicons } from "@expo/vector-icons"

export default function TabLayout() {
  return (
    <Tabs>
      <Tabs.Screen name="index" options={{
        title: "Home",
        tabBarIcon: ({ color }) => <Ionicons name="home" size={24} color={color} />
      }} />
      <Tabs.Screen name="profile" options={{
        title: "Profile",
        tabBarIcon: ({ color }) => <Ionicons name="person" size={24} color={color} />
      }} />
    </Tabs>
  )
}

// Navigation between screens
import { Link, useRouter } from "expo-router"

// Declarative
<Link href="/profile">Go to Profile</Link>

// Imperative
const router = useRouter()
router.push("/profile")
router.replace("/login")
router.back()
```

### 3. Styling with NativeWind

```bash
npx expo install nativewind tailwindcss
```

```typescript
// NativeWind: use Tailwind classes on React Native components
import { View, Text, Pressable } from "react-native"

export function Card({ title, description }: Props) {
  return (
    <View className="bg-white rounded-xl p-4 shadow-md mx-4 my-2">
      <Text className="text-lg font-bold text-gray-900">{title}</Text>
      <Text className="text-sm text-gray-500 mt-1">{description}</Text>
      <Pressable className="bg-blue-500 rounded-lg py-2 px-4 mt-3 active:bg-blue-600">
        <Text className="text-white text-center font-medium">Action</Text>
      </Pressable>
    </View>
  )
}
```

### 4. Data Fetching

Use TanStack Query (same patterns as web):

```typescript
import { useQuery } from "@tanstack/react-query"

export function useUsers() {
  return useQuery({
    queryKey: ["users"],
    queryFn: () => fetch("https://api.example.com/users").then((r) => r.json())
  })
}
```

### 5. EAS Build and Deploy

```bash
# Install EAS CLI
npm install -g eas-cli
eas login

# Configure builds
eas build:configure

# Development build (with dev client)
eas build --platform all --profile development

# Production build
eas build --platform all --profile production

# Submit to stores
eas submit --platform ios
eas submit --platform android
```

```json
// eas.json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal"
    },
    "production": {}
  },
  "submit": {
    "production": {
      "ios": { "appleId": "your@email.com" },
      "android": { "serviceAccountKeyPath": "./google-services.json" }
    }
  }
}
```

### 6. Common Patterns

```typescript
// Push notifications
import * as Notifications from "expo-notifications"
import { useEffect } from "react"

export function usePushNotifications() {
  useEffect(() => {
    Notifications.requestPermissionsAsync().then(({ status }) => {
      if (status === "granted") {
        Notifications.getExpoPushTokenAsync().then(({ data }) => {
          // Send token to your server
        })
      }
    })
  }, [])
}

// Camera / Image picker
import * as ImagePicker from "expo-image-picker"

async function pickImage() {
  const result = await ImagePicker.launchImageLibraryAsync({
    mediaTypes: ImagePicker.MediaTypeOptions.Images,
    allowsEditing: true,
    quality: 0.8
  })
  if (!result.canceled) return result.assets[0].uri
}

// Secure storage
import * as SecureStore from "expo-secure-store"

await SecureStore.setItemAsync("token", authToken)
const token = await SecureStore.getItemAsync("token")
```

## Rules

1. Expo is ALWAYS recommended over bare React Native CLI for new projects
2. Expo Router is ALWAYS recommended over React Navigation for new projects
3. NativeWind for styling (Tailwind for RN, consistent with web skills)
4. EAS for builds, ALWAYS over local Xcode/Gradle builds
5. Test on BOTH iOS and Android before shipping
6. Use expo-secure-store for sensitive data, NEVER AsyncStorage
7. Use TanStack Query for data fetching (same as web)
8. Use TypeScript strict mode (same as web)

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Bare RN CLI for new projects | Complex setup, no managed workflow | Expo (zero-config, OTA updates) |
| React Navigation manual setup | Verbose, no file-based routing | Expo Router (file-based, like Next.js) |
| StyleSheet.create everywhere | Verbose, no design tokens | NativeWind (Tailwind classes) |
| Local Xcode/Gradle builds | Slow, environment-dependent | EAS Build (cloud, reproducible) |
| AsyncStorage for tokens | Not encrypted, security risk | expo-secure-store |
| Not testing on both platforms | Platform-specific bugs | Always verify iOS + Android |
