import SwiftUI

struct SizePreferenceKey: PreferenceKey {
  static let defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

extension View {
  /// Calls `perform` whenever this view's size changes (including after first layout).
  /// Uses `PreferenceKey` so it's compatible with all supported OS versions.
  @ViewBuilder
  func onSizeChange(_ perform: @escaping (CGSize) -> Void) -> some View {
    if #available(iOS 26, visionOS 26.0, macOS 26.0, *) {
      self
    } else {
      background(
        GeometryReader { geo in
          Color.clear.preference(key: SizePreferenceKey.self, value: geo.size)
        }
      )
      .onPreferenceChange(SizePreferenceKey.self, perform: perform)
    }
  }
}
