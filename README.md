# StatsPriorityColors

**StatsPriorityColors** is a lightweight World of Warcraft addon designed for **Cataclysm Classic** (Interface 40400). It enhances item tooltips by color-coding stats based on their relevance to your character's specialization, helping you quickly identify gear that suits your playstyle.

## Features

- **Dynamic Stat Highlighting**: Stats relevant to your current specialization are highlighted in **bright orange**, while stats useful for other specializations of your class are shown in **purple**.
- **Seamless Integration**: Automatically updates when you change your specialization, ensuring accurate stat highlighting.
- **Performance-Friendly**: Built to be lightweight with minimal impact on game performance.
- **Debug Logging**: Includes a robust logging system to help troubleshoot issues (saved per character).

https://github.com/user-attachments/assets/6cb265ea-c9e5-4900-ae73-63bf199a1dec

## Installation

1. **Download** the latest release from the [Releases](https://github.com/CryptoLogiq/StatsPriorityColors/releases) page or clone the repository.
2. **Extract** the `StatsPriorityColors` folder to your WoW AddOns directory:
3. **Launch WoW**: Ensure the addon is enabled in the AddOns menu at the character selection screen.
4. **Enjoy**: Hover over items in-game to see color-coded stats in tooltips!

## Usage

- The addon automatically detects your character's class and specialization.
- When you hover over an item, relevant stats are highlighted:
  - **Bright Orange**: Stats optimal for your current specialization.
  - **Purple**: Stats useful for other specializations of your class.
- Logs are saved to help diagnose any issues (stored in `WTF\Account\<YourAccount>\SavedVariables\StatsPriorityColors.lua`).

## Compatibility

- Designed for **World of Warcraft: Cataclysm Classic** (Interface 40400).
- Tested with standard UI tooltips. May require adjustments for heavily customized UI addons.

## Contributing

Contributions are welcome! If you'd like to add features, fix bugs, or improve the addon:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -m 'Add your feature'`).
4. Push to your branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

Please include a clear description of your changes and test them in-game before submitting.

## Issues

Found a bug or have a suggestion? Open an issue on the [Issues](https://github.com/CryptoLogiq/StatsPriorityColors/issues) page. Include:
- A detailed description of the problem or suggestion.
- Steps to reproduce the issue (if applicable).
- Any relevant logs from `SavedVariables\StatsPriorityColors.lua`.

## Credits

- **Author**: Crypto_Logiq
- Built with love for the WoW Classic community.

## License

This project is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute it as per the license terms.

---

Happy adventuring in Azeroth!
