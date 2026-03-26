# Spec Card: react-native-expo

## Identity
- **Pack:** full-stack
- **Sub-pack:** frontend
- **Layer:** userland

## Scope
Mobile app development with React Native and Expo. Covers project setup, navigation (Expo Router), styling, native modules, deployment (EAS), and cross-platform patterns. OSS-first: Expo (OSS) is primary. React Native CLI as "aware of" for ejected/bare projects.

Does NOT cover: Flutter, native iOS/Android development, or backend APIs for mobile (covered by backend sub-pack).

## Expected Inputs
- User wants to build a mobile app with React Native
- User mentions Expo, Expo Router, EAS, React Native, mobile development
- User migrating from web (Next.js) to mobile

## Expected Outputs
- Expo project setup with TypeScript and Expo Router
- Navigation patterns (file-based routing with Expo Router)
- Styling patterns (StyleSheet, NativeWind/Tailwind, Tamagui)
- Native module integration and EAS Build/Submit
- Cross-platform code sharing patterns (web + mobile)

## Must-Have Features
1. Expo project initialization with TypeScript
2. Expo Router file-based navigation (tabs, stacks, modals)
3. Styling: NativeWind (Tailwind for RN) as primary
4. Data fetching with TanStack Query
5. EAS Build configuration (development, preview, production)
6. EAS Submit (App Store, Google Play)
7. Push notifications with expo-notifications
8. Camera, image picker, and media handling

## Nice-to-Have Features
1. Expo Dev Client for custom native modules
2. OTA updates with EAS Update
3. Deep linking and universal links
4. Performance optimization (FlashList, Reanimated)
5. Web support (React Native Web via Expo)

## Anti-Patterns
- Using React Native CLI for new projects (Expo is the standard in 2026)
- StyleSheet.create without considering NativeWind
- Not using Expo Router (manual React Navigation setup)
- Building without EAS (manual Xcode/Android Studio builds)

## Integration Points
- `auth-patterns`: Mobile auth flows (OAuth, biometrics)
- `state-management`: Zustand/TanStack Query in mobile
- `ai-integration`: AI features in mobile apps
- `typescript-pro`: Shared types between web and mobile

## Success Criteria
- Can scaffold and run Expo app in under 3 minutes
- Navigation with tabs + stack works correctly
- EAS Build produces installable builds for both platforms
- NativeWind styling works with Tailwind classes

## Key Rules
- Expo is ALWAYS recommended over bare React Native CLI
- Expo Router is ALWAYS recommended over React Navigation for new projects
- NativeWind for styling (Tailwind CSS for React Native)
- EAS for builds, ALWAYS over local Xcode/Gradle builds
- Test on both iOS and Android before shipping
