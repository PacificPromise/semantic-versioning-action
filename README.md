# Semantic versioning without any track files.

**This action uses git tag for controlling the version. This action will not change/add/remove any file in your repository.**

## How to use

### 1 - Use github action

**you can check `.github/workflows/debug-ubuntu.yml` file for more details**

```yml
- name: Run semantic versioning
  uses: PacificPromise/semantic-versioning-action@main
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  with:
    script: increment_core_tag patch
```

**Scripts define** (`increment_core_tag <increment type>`) patch, minor, major

- `increment_core_tag patch`: Increment patch version (1.0.xx)
- `increment_core_tag minor`: Increment minor version (1.xx.0)
- `increment_core_tag major`: Increment major version (xx.0.0)

**Pre-release version**: (`increment_tag <pre-release>`) alpha, beta, dev, stg, prd

- `increment_tag alpha`: Increment pre-release alpha version
- `increment_tag beta`: Increment pre-release beta version
- `increment_tag dev`: Increment development environment
- `increment_tag stg`: Increment staging environment
- `increment_tag uat`: Increment UAT environment

### 2 - Use script: run this script in your repository

- Create a sh file with below content `run_sample.sh`.

```sh
source /dev/stdin <<<"$(curl -s https://raw.githubusercontent.com/PacificPromise/semantic-versioning-action/main/index.sh)" && get_stage_prompt

```

- Run that file with bash (on Windows with [git bash](https://gitforwindows.org/))

```sh
bash run_sample.sh
```

- Script will show the menu options:

```bash
Action:
Action:
1) Increment development environment  5) Increment patch version (1.0.xx)
2) Increment staging environment      6) Increment minor version (1.xx.0)
3) Increment UAT environment          7) Increment major version (xx.0.0)
4) Increment product environment      8) Quit
Choose: 1
Chose option: Increment development environment
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 171 bytes | 171.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0), pack-reused 0
To github.com:tuanngocptn/semantic-versioning-action.git
 * [new tag]         v5.0.4-dev+1 -> v5.0.4-dev+1
```

## Contributors ✨

Thanks go to these wonderful people:

<!-- readme: collaborators,contributors -start -->
<table>
	<tbody>
		<tr>
            <td align="center">
                <a href="https://github.com/baronha">
                    <img src="https://avatars.githubusercontent.com/u/23580920?v=4" width="100;" alt="baronha"/>
                    <br />
                    <sub><b>Bảo Hà.</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/tuanngocptn">
                    <img src="https://avatars.githubusercontent.com/u/22292704?v=4" width="100;" alt="tuanngocptn"/>
                    <br />
                    <sub><b>Nick - Ngoc Pham</b></sub>
                </a>
            </td>
		</tr>
	<tbody>
</table>
<!-- readme: collaborators,contributors -end -->

### Thanks for using Semantic Versioning Action
