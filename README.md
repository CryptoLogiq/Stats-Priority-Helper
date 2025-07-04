# Stats Priority Helper

**Stats Priority Helper** is a lightweight World of Warcraft addon designed for **Cataclysm Classic** (Interface 40400). It enhances item tooltips by color-coding stats based on their relevance to your character's specialization, helping you quickly identify gear that suits your playstyle.

## Features

- **Dynamic Stat Highlighting**: Stats relevant to your current specialization are highlighted in **bright orange**, while stats useful for other specializations of your class are shown in **purple**.
- **Seamless Integration**: Automatically updates when you change your specialization, ensuring accurate stat highlighting.

- It's not a comparaison with your current gear, it's just for help you for choices of your pieces of gear.

(Alpha preview, not representative to actually state of addon.)

https://github.com/user-attachments/assets/6cb265ea-c9e5-4900-ae73-63bf199a1dec

## Examples with items

__Example with item recommandation for you :__

![image](https://github.com/user-attachments/assets/9de8c9db-c268-443b-8840-427e53df223f)


__Example with item not recommanded for your specs :__

![image](https://github.com/user-attachments/assets/172b73a7-b243-454b-87b9-27bc98ce6d69)

## Installation

1. **Download** the latest release from the [Releases](https://github.com/CryptoLogiq/Stats-Priority-Helper/releases) page or clone the repository.
2. **Extract** the `Stats Priority Helper` folder to your WoW AddOns directory: "World of Warcraft/.../Interface/Addons/"
3. **Launch WoW**: Ensure the addon is enabled in the AddOns menu at the character selection screen.
4. **Enjoy**: Hover over items in-game to see color-coded stats in tooltips!

## Usage

- The addon automatically detects your character's class and specialization.
- When you hover over an item, relevant stats are highlighted:
  - **Bright Orange**: Stats optimal for your current specialization.
  - **Blue Cyan**: Stats useful for your secondary specialization.
  - **Red**: Stats useless for yours one or two specialisations learned.

## Compatibility

- Designed for **World of Warcraft: Cataclysm Classic** (Interface 40400).
- Tested with standard UI tooltips and Elvui. May require adjustments for heavily customized UI addons (feedback me if you have troubles).

## Contributing

Contributions are welcome! If you'd like to add features, fix bugs, or improve the addon:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -m 'Add your feature'`).
4. Push to your branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

Please include a clear description of your changes and test them in-game before submitting.

## Issues

Found a bug or have a suggestion? Open an issue on the [Issues](https://github.com/CryptoLogiq/Stats-Priority-Helper/issues) page. Include:
- A detailed description of the problem or suggestion.
- Steps to reproduce the issue (if applicable).
- Any relevant logs from `SavedVariables\StatsPriority.lua`.

## Credits

- **Author**: Crypto_Logiq
- Built with love for the WoW Classic community.

## License

This project is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute it as per the license terms.

---

Happy adventuring in Azeroth!
