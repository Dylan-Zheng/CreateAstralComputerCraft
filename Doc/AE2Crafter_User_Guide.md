# AE2Crafter User Guide

## Overview

AE2Crafter is an automated crafting system designed for ComputerCraft and Applied Energistics 2 (AE2). It enables intelligent item crafting and management through Turtle and AE2 network integration.

## System Components

### Hardware Requirements
- **Advenced Turtle** - Core device for executing crafting operations
- **AE2 Pattern Provider** - Connects to AE2 network
- **Item Vault** - Stores raw materials
- **Chest** - Temporary storage for crafted items
- **Dropper** - Acts as material buffer
- **Trapped Chest** - Used for reading crafting recipes

## Installation and Configuration

### 1. Block Layout
![AE2Crafter Setup - Front](https://github.com/Dylan-Zheng/CreateAstralComputerCraft/blob/main/Doc/images/ae2crafter/AE2CrafterSetup-front.png?raw=true)
![AE2Crafter Setup - Back](https://github.com/Dylan-Zheng/CreateAstralComputerCraft/blob/main/Doc/images/ae2crafter/AE2CrafterSetup-back.png?raw=true)

### 2. Setup
1. run this below command in turtle:
   - wget https://raw.githubusercontent.com/Dylan-Zheng/CreateAstralComputerCraft/refs/heads/main/release/AE2Crafter.lua startup
2. schematic:
   - https://github.com/Dylan-Zheng/CreateAstralComputerCraft/raw/refs/heads/main/Doc/schematic/ae2_crafter.nbt
3. AE2 Pattern Encodeing with 1x or 2x speed. 
   - To increasing the crafting speed just increasing number of input, output and markitem
![Create AE2 Pattern - 1X](https://github.com/Dylan-Zheng/CreateAstralComputerCraft/blob/main/Doc/images/ae2crafter/PatternEncoding_1x_speed.png?raw=true)
![Create AE2 Pattern - 2X](https://github.com/Dylan-Zheng/CreateAstralComputerCraft/blob/main/Doc/images/ae2crafter/PatternEncoding_2x_speed.png?raw=true)
4. Find Turtle Crafting Partting Chest (Trapped Chest)
![Turtle Pattern Chest](https://github.com/Dylan-Zheng/CreateAstralComputerCraft/blob/main/Doc/images/ae2crafter/FindTrappedChest.png?raw=true)
5. Create A Turtle Crafting Pattern
![Turtle Pattern Chest](https://github.com/Dylan-Zheng/CreateAstralComputerCraft/blob/main/Doc/images/ae2crafter/CreateTurtlePatternA.png?raw=true)
![Turtle Pattern Chest](https://github.com/Dylan-Zheng/CreateAstralComputerCraft/blob/main/Doc/images/ae2crafter/CreateTurtlePatternB.png?raw=true)
![Turtle Pattern Chest](https://github.com/Dylan-Zheng/CreateAstralComputerCraft/blob/main/Doc/images/ae2crafter/CreateTurtlePatternC.png?raw=true)

## Usage

### Applied Energistics 2 Configuration

1. **Pattern Type**: You must use **Processing Patterns** (not Crafting Patterns)
2. **Pattern Setup**:
   - The crafting layout is not required in the pattern
   - However, the quantity of input and output items must match your actual crafting recipe
3. **Mark Item Requirement**: 
   - Include the mark item in your processing pattern
   - This allows the AE2 system to identify which recipe to execute
4. **Performance Optimization**: 
   - To increase crafting speed, provide more input items and mark items in the pattern

### Recipe Management

#### 1. Read Recipe (Read)
1. Place crafting materials in the trapped chest following a 3x3 grid pattern (slots 1,2,3,10,11,12,19,20,21)
2. Place the crafting result in slot 4
3. Place the Mark Item in slot 13
   - **Important**: Each recipe requires a unique mark item with different NBT data (custom name)
   - You can use the same item type for different recipes, but each must have a unique custom name
   - **How to create mark items**: Use an anvil to rename any item (e.g., "Iron Recipe", "Gold Recipe")
   - The custom name serves as the unique identifier for each crafting recipe 
4. Click the **Read** button to read the recipe

#### 2. Save Recipe (Save)
1. Confirm the recipe information in the right text box is correct
2. Click the **Save** button to save the recipe
3. The system will automatically validate the recipe

#### 3. Delete Recipe (Del)
1. Select the recipe to delete from the left list
2. Click the **Del** button to delete the selected recipe

### Recipe Validation Rules

The system automatically validates the following rules:

1. **Mark items cannot be used as input materials**
   - Mark items must be independent of the crafting recipe

2. **Mark items cannot be the same as output**
   - Prevents logical conflicts

3. **Recipe conflict detection**
   - The same mark item cannot be used for different crafting recipes
   - Ensures each mark item corresponds to a unique crafting recipe

### Automated Crafting Process

#### Crafting Steps
1. **Preparation Phase (PREPARE_ITEM)**
   - Move mark items to output chest
   - Move crafting materials from inventory to buffer
   - Turtle retrieves materials from buffer

2. **Checking Phase (CHECKING)**
   - Verify materials in turtle's inventory are correct
   - Confirm quantities and positions

3. **Crafting Phase (CRAFT)**
   - Turtle executes crafting operation

4. **Output Phase (DROP_OUTPUT)**
   - Drop crafting results into output chest

5. **Recovery Phase (PROVIDER_TAKE_OUTPUT)**
   - Move finished products to AE2 network
   - Recover mark items

#### Error Handling
- System has resume functionality
- Saves current state when any step fails
- Automatically resumes from interruption point on next startup

## Interface Description

### Main Interface Layout
```
┌─────────────────┬─────────────────────────┐
│ Recipe List     │ Recipe Details          │
│ - Iron Ingot abc│ {                       │
│ - Gold Ingot def│   input = {...},        │
│ - Diamond ghi   │   output = {...},       │
│                 │   mark = {...}          │
│                 │ }                       │
├─────────────────┴─────────────────────────┤
│ [Read] [Save] [Del]                       │
└───────────────────────────────────────────┘
```

### Logging System
- Real-time display of system running status
- Auto-scroll to show latest information

## Troubleshooting

### Common Issues

1. **"Mark item cannot be used as input item"**
   - Solution: Change mark item, ensure it doesn't duplicate crafting materials

2. **"Failed to move output item after multiple attempts"**
   - Check AE2 network connection
   - Confirm pattern provider has sufficient space

3. **"No valid mark item found in slot 13"**
   - Check if trapped chest slot 13 has an item with NBT data
   - Ensure item has unique identifier
   

