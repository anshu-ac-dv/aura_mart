# Implementation Plan - Redesign and Responsive Dashboard

The goal is to update `dashboard_tab.dart` with a modern, "premium" design while ensuring it is responsive across different screen sizes (phones, tablets, etc.).

## Proposed Changes

### [Component Name] Dashboard Tab Redesign

#### [MODIFY] [dashboard_tab.dart](file:///C:/Users/anshu/StudioProjects/aura_mart/lib/screens/tabs/dashboard_tab.dart)

1.  **Dynamic Column Count**:
    - Implement a helper method to calculate the number of columns based on screen width (e.g., 2 for phone, 3 or 4 for tablets).
2.  **Promotional Banner**:
    - Add a `SliverToBoxAdapter` containing a horizontal carousel for featured items or promotions before the product grid.
3.  **Enhanced App Bar**:
    - Improve the `SliverAppBar` with a cleaner gradient and better spacing.
    - Make the "Aura Mart" title animate or transition more smoothly.
4.  **Refined Search Bar**:
    - Update the search bar design with better shadows and interactive feel.
5.  **Modern Category Chips**:
    - Redesign the categories list to be more visually engaging, possibly adding subtle icons or better color states.
6.  **Premium Product Cards**:
    - Update `_buildModernProductCard` with:
        - Improved typography.
        - Better shadow and border-radius.
        - Subtle animations on hover (if applicable) or tap.
        - Display "Seller Name" subtly to add "premium" feel.
7.  **Responsive Spacing**:
    - Use `MediaQuery` to adjust horizontal padding and vertical gaps between sections based on screen width.

## Verification Plan

### Manual Verification
- Test on different screen sizes (Portrait/Landscape) using the Flutter Emulator.
- Verify that the grid columns adjust correctly.
- Ensure the UI looks clean in both Dark and Light modes.
- Verify that search and category filtering still work perfectly.
