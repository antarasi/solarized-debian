FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=22
ENV SHELL=/bin/zsh

# Install base packages
RUN apt-get update && apt-get install -y \
    zsh \
    git \
    curl \
    wget \
    ca-certificates \
    locales \
    fonts-powerline \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Set zsh as default shell for root
RUN chsh -s /bin/zsh root

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install zsh-autosuggestions plugin
RUN git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install zsh-syntax-highlighting plugin
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Configure .zshrc: set theme and plugins
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' /root/.zshrc && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' /root/.zshrc

# Install Solarized Dark dircolors
RUN git clone https://github.com/seebi/dircolors-solarized /root/.dircolors-solarized && \
    echo 'eval $(dircolors /root/.dircolors-solarized/dircolors.ansi-dark)' >> /root/.zshrc

# Install NVM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

# Install Node 22 via NVM and set as default
RUN bash -c "source /root/.nvm/nvm.sh && nvm install ${NODE_VERSION} && nvm alias default ${NODE_VERSION} && nvm use default"

# Add NVM sourcing to .zshrc (oh-my-zsh install already adds it, but ensure it's present)
RUN grep -q 'NVM_DIR' /root/.zshrc || \
    printf '\nexport NVM_DIR="$HOME/.nvm"\n[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"\n[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"\n' >> /root/.zshrc

# Make node/npm available in PATH for non-interactive shells
RUN bash -c "source /root/.nvm/nvm.sh && ln -sf \$(which node) /usr/local/bin/node && ln -sf \$(which npm) /usr/local/bin/npm && ln -sf \$(which npx) /usr/local/bin/npx"

WORKDIR /root

CMD ["/bin/zsh"]
